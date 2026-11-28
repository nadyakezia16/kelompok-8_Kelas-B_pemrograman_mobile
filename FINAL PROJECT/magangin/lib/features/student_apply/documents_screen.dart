
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/document_item.dart';
import '../../repositories/interfaces/document_repository.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late Future<List<DocumentItem>> _documentsFuture;

  static const List<_DocumentCategory> _categories = [
    _DocumentCategory(
      title: 'CV',
      type: 'cv',
      description: 'Curriculum Vitae',
      icon: Icons.description_outlined,
    ),
    _DocumentCategory(
      title: 'Surat Pengantar Magang dari Kampus',
      type: 'internship_letter',
      description: 'Surat resmi dari kampus',
      icon: Icons.mail_outline,
    ),
    _DocumentCategory(
      title: 'KHS',
      type: 'khs',
      description: 'Kartu Hasil Studi',
      icon: Icons.school_outlined,
    ),
    _DocumentCategory(
      title: 'Proposal Magang',
      type: 'internship_proposal',
      description: 'Proposal pengajuan magang',
      icon: Icons.assignment_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _documentsFuture = _loadDocuments();
  }

  Future<List<DocumentItem>> _loadDocuments() {
    return context.read<DocumentRepository>().listMyDocuments();
  }

  Future<void> _refreshDocuments() async {
    setState(() {
      _documentsFuture = _loadDocuments();
    });

    await _documentsFuture;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _uploadDocument(_DocumentCategory category) async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (files.isEmpty) return;

      final selectedFile = files.first;
      final path = selectedFile.path;

      if (path == null) {
        _showMessage('File tidak dapat dibaca.');
        return;
      }

      if (!path.toLowerCase().endsWith('.pdf')) {
        _showMessage('File harus berformat PDF.');
        return;
      }

      final file = File(path);
      final fileSize = await file.length();

      if (fileSize > 5 * 1024 * 1024) {
        _showMessage('Ukuran file maksimal 5 MB.');
        return;
      }

      if (!mounted) return;

      final uploadedDocument = await context
          .read<DocumentRepository>()
          .uploadDocument(
        file: file,
        type: category.type,
        name: selectedFile.name,
      );

      if (!mounted) return;

      setState(() {
        _documentsFuture = _loadDocuments();
      });

      _showMessage(
        '${uploadedDocument.name} berhasil diunggah.',
      );
    } catch (e) {
      _showMessage('Gagal mengunggah dokumen: $e');
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      color: AppColors.background,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.primary,
            ),
          ),
          Image.asset(
            'assets/images/magangin_logo.png',
            width: 38,
            height: 38,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.school,
                color: AppColors.primary,
                size: 34,
              );
            },
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Dokumen Saya',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const CircleAvatar(
            radius: 19,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard(bool hasKhs) {
    final statusColor = hasKhs
        ? AppColors.warning
        : AppColors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: AppColors.primary,
                size: 23,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Status Verifikasi Dokumen',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172B4D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              hasKhs ? 'Menunggu Verifikasi' : 'Belum Diunggah',
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hasKhs
                ? 'Dokumen KHS kamu sudah tersedia dan menunggu proses verifikasi.'
                : 'Unggah dokumen KHS agar proses verifikasi dapat dilakukan.',
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(DocumentItem document) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.picture_as_pdf_outlined,
              color: AppColors.primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF172B4D),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'PDF • Diunggah ${_formatDate(document.createdAt)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required _DocumentCategory category,
    required List<DocumentItem> documents,
  }) {
    final filteredDocuments = documents
        .where((document) => document.type == category.type)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF172B4D),
          ),
        ),
        const SizedBox(height: 10),

        if (filteredDocuments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  category.icon,
                  size: 32,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Belum ada dokumen',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _uploadDocument(category),
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Unggah PDF'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.button,
                    side: const BorderSide(
                      color: AppColors.button,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...filteredDocuments.map(_buildDocumentCard),
      ],
    );
  }

  Widget _buildContent(List<DocumentItem> documents) {
    final hasKhs = documents.any(
          (document) => document.type == 'khs',
    );

    return RefreshIndicator(
      onRefresh: _refreshDocuments,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildVerificationCard(hasKhs),
          const SizedBox(height: 24),

          for (int i = 0; i < _categories.length; i++) ...[
            _buildSection(
              category: _categories[i],
              documents: documents,
            ),
            if (i != _categories.length - 1)
              const SizedBox(height: 22),
          ],

          const SizedBox(height: 20),
          const Text(
            'Format dokumen PDF dengan ukuran maksimal 5 MB.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: FutureBuilder<List<DocumentItem>>(
                future: _documentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 40,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Gagal memuat dokumen.',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _refreshDocuments,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final documents = snapshot.data ?? [];

                  return _buildContent(documents);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentCategory {
  final String title;
  final String type;
  final String description;
  final IconData icon;

  const _DocumentCategory({
    required this.title,
    required this.type,
    required this.description,
    required this.icon,
  });
}
