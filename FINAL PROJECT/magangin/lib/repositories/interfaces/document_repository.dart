import 'dart:io';

import '../../models/document_item.dart';

abstract class DocumentRepository {
  Future<List<DocumentItem>> listMyDocuments({
    String? type,
  });

  Future<DocumentItem> uploadDocument({
    required File file,
    required String type,
    required String name,
  });

  Future<DocumentItem> renameDocument({
    required String id,
    required String name,
  });

  Future<void> deleteDocument(String id);

  Future<String> getSignedUrl(String documentId);
}