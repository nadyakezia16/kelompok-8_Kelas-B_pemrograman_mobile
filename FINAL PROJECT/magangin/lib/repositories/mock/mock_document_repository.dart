
import 'dart:io';

import '../../models/document_item.dart';
import '../interfaces/document_repository.dart';

class MockDocumentRepository implements DocumentRepository {
  final List<DocumentItem> _documents = [
    DocumentItem(
      id: 'doc-001',
      ownerId: 'student-001',
      type: 'cv',
      name: 'CV Andi Pratama',
      filePath: 'mock/cv_andi.pdf',
      createdAt: DateTime(2026, 11, 20),
    ),
    DocumentItem(
      id: 'doc-002',
      ownerId: 'student-001',
      type: 'khs',
      name: 'KHS Semester 4',
      filePath: 'mock/khs_andi.pdf',
      createdAt: DateTime(2026, 11, 21),
    ),
  ];

  @override
  Future<List<DocumentItem>> listMyDocuments({String? type}) async {
    if (type == null) {
      return List.unmodifiable(_documents);
    }

    return List.unmodifiable(
      _documents.where((document) => document.type == type),
    );
  }

  @override
  Future<DocumentItem> uploadDocument({
    required File file,
    required String type,
    required String name,
  }) async {
    if (!file.path.toLowerCase().endsWith('.pdf')) {
      throw Exception('Dokumen harus berformat PDF.');
    }

    final fileSize = await file.length();

    if (fileSize > 5 * 1024 * 1024) {
      throw Exception('Ukuran dokumen maksimal 5 MB.');
    }

    final document = DocumentItem(
      id: 'doc-${DateTime.now().microsecondsSinceEpoch}',
      ownerId: 'student-001',
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
    final exists = _documents.any(
          (document) => document.id == id,
    );

    if (!exists) {
      throw Exception('Dokumen tidak ditemukan.');
    }

    _documents.removeWhere((document) => document.id == id);
  }

  @override
  Future<String> getSignedUrl(String documentId) async {
    final exists = _documents.any(
          (document) => document.id == documentId,
    );

    if (!exists) {
      throw Exception('Dokumen tidak ditemukan.');
    }

    return 'https://mock-magangin.com/documents/$documentId';
  }
}
