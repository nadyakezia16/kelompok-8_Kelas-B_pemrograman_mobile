
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config.dart';
import '../../core/theme/app_theme.dart';
import '../../models/document_item.dart';
import '../../repositories/interfaces/document_repository.dart';
import 'documents_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DocumentsPreviewApp());
}

class DocumentsPreviewApp extends StatelessWidget {
  const DocumentsPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<DocumentRepository>(
      create: (_) => _PreviewDocumentRepository(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        home: const DocumentsScreen(),
      ),
    );
  }
}

class _PreviewDocumentRepository implements DocumentRepository {
  final List<DocumentItem> _documents = [];

  @override
  Future<List<DocumentItem>> listMyDocuments({
    String? type,
  }) async {
    if (type == null) {
      return List.unmodifiable(_documents);
    }

    return _documents
        .where((document) => document.type == type)
        .toList();
  }

  @override
  Future<DocumentItem> uploadDocument({
    required File file,
    required String type,
    required String name,
  }) async {
    final document = DocumentItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      ownerId: 'preview-user',
      type: type,
      name: name,
      filePath: file.path,
      createdAt: DateTime.now(),
    );

    _documents.add(document);

    return document;
  }

  @override
  Future<DocumentItem> renameDocument({
    required String id,
    required String name,
  }) async {
    final index = _documents.indexWhere(
          (document) => document.id == id,
    );

    if (index == -1) {
      throw Exception('Dokumen tidak ditemukan.');
    }

    final oldDocument = _documents[index];

    final updatedDocument = DocumentItem(
      id: oldDocument.id,
      ownerId: oldDocument.ownerId,
      type: oldDocument.type,
      name: name,
      filePath: oldDocument.filePath,
      createdAt: oldDocument.createdAt,
    );

    _documents[index] = updatedDocument;

    return updatedDocument;
  }

  @override
  Future<void> deleteDocument(String id) async {
    _documents.removeWhere(
          (document) => document.id == id,
    );
  }

  @override
  Future<String> getSignedUrl(String documentId) async {
    final document = _documents.firstWhere(
          (item) => item.id == documentId,
      orElse: () => throw Exception('Dokumen tidak ditemukan.'),
    );

    return Uri.file(document.filePath).toString();
  }
}
