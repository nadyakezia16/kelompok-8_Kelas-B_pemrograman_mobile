
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/supabase_config.dart';
import '../../models/document_item.dart';
import '../interfaces/document_repository.dart';

class SupabaseDocumentRepository implements DocumentRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  static const String _bucket = 'documents';
  static const int _maxFileSize = 5 * 1024 * 1024;

  String get _userId {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    return user.id;
  }

  @override
  Future<List<DocumentItem>> listMyDocuments({
    String? type,
  }) async {
    var request = _client
        .from('documents')
        .select()
        .eq('profile_id', _userId);

    if (type != null && type.isNotEmpty) {
      request = request.eq('document_type', type);
    }

    final response = await request.order(
      'created_at',
      ascending: false,
    );

    return (response as List)
        .map((item) => DocumentItem.fromJson({
              'id': item['id'],
              'owner_id': item['profile_id'],
              'type': item['document_type'],
              'name': item['file_name'],
              'file_path': item['storage_path'],
              'created_at': item['created_at'],
            }))
        .toList();
  }

  @override
  Future<DocumentItem> uploadDocument({
    required File file,
    required String type,
    required String name,
  }) async {
    if (!await file.exists()) {
      throw Exception('File tidak ditemukan.');
    }

    if (type.isEmpty ||
        !['cv', 'khs', 'portfolio', 'other'].contains(type)) {
      throw Exception('Jenis dokumen tidak valid.');
    }

    final extension = file.path.split('.').last.toLowerCase();

    if (extension != 'pdf') {
      throw Exception('Dokumen harus berformat PDF.');
    }

    final fileSize = await file.length();

    if (fileSize > _maxFileSize) {
      throw Exception('Ukuran dokumen maksimal 5 MB.');
    }

    final userId = _userId;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '$userId/${type}_$timestamp.pdf';

    await _client.storage.from(_bucket).upload(
      filePath,
      file,
      fileOptions: const FileOptions(
        contentType: 'application/pdf',
        upsert: false,
      ),
    );

    try {
      final response = await _client
          .from('documents')
          .insert({
            'profile_id': userId,
            'document_type': type,
            'file_name': name,
            'storage_path': filePath,
          })
          .select()
          .single();

      return DocumentItem.fromJson({
        'id': response['id'],
        'owner_id': response['profile_id'],
        'type': response['document_type'],
        'name': response['file_name'],
        'file_path': response['storage_path'],
        'created_at': response['created_at'],
      });
    } catch (_) {
      await _client.storage.from(_bucket).remove([filePath]);
      rethrow;
    }
  }

  @override
  Future<DocumentItem> renameDocument({
    required String id,
    required String name,
  }) async {
    final response = await _client
        .from('documents')
        .update({'file_name': name})
        .eq('id', id)
        .eq('profile_id', _userId)
        .select()
        .single();

    return DocumentItem.fromJson({
      'id': response['id'],
      'owner_id': response['profile_id'],
      'type': response['document_type'],
      'name': response['file_name'],
      'file_path': response['storage_path'],
      'created_at': response['created_at'],
    });
  }

  @override
  Future<void> deleteDocument(String id) async {
    final document = await _client
        .from('documents')
        .select('storage_path')
        .eq('id', id)
        .eq('profile_id', _userId)
        .single();

    final filePath = document['storage_path'] as String;

    await _client.storage.from(_bucket).remove([filePath]);

    await _client
        .from('documents')
        .delete()
        .eq('id', id)
        .eq('profile_id', _userId);
  }

  @override
  Future<String> getSignedUrl(String documentId) async {
    final document = await _client
        .from('documents')
        .select('storage_path')
        .eq('id', documentId)
        .eq('profile_id', _userId)
        .single();

    final filePath = document['storage_path'] as String;

    return _client.storage
        .from(_bucket)
        .createSignedUrl(filePath, 3600);
  }
}
