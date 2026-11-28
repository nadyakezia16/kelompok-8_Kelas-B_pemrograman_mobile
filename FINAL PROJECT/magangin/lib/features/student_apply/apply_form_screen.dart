
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/job.dart';
import '../../models/profile.dart';
import '../../models/document_item.dart';
import '../../repositories/interfaces/document_repository.dart';
import '../../repositories/interfaces/application_repository.dart';
import 'submitted_application_screen.dart';

class ApplyFormScreen extends StatefulWidget {
  final Job job;
  final Profile profile;

  const ApplyFormScreen({
    super.key,
    required this.job,
    required this.profile,
  });

  @override
  State<ApplyFormScreen> createState() => _ApplyFormScreenState();
}

class _ApplyFormScreenState extends State<ApplyFormScreen> {
  late Future<List<DocumentItem>> _documentsFuture;

  String? _selectedCvId;
  bool _agreementAccepted = false;
  bool _isSubmitting = false;

  final TextEditingController _messageController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    _documentsFuture = _loadDocuments();
  }

  Future<List<DocumentItem>> _loadDocuments() {
    return context.read<DocumentRepository>().listMyDocuments();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // KIRIM LAMARAN
  Future<void> _submitApplication() async {
    if (_isSubmitting ||
        _selectedCvId == null ||
        !_agreementAccepted) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final message = _messageController.text.trim();

      final application =
      await context.read<ApplicationRepository>().apply(
        jobId: widget.job.id,
        cvDocumentId: _selectedCvId!,
        message: message.isEmpty ? null : message,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SubmittedApplicationScreen(
            application: application,
            job: widget.job,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim lamaran: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // HEADER
  Widget _buildHeader() {
    final avatarUrl = widget.profile.avatarUrl;

    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 5, 16, 10),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 2),
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(
                  'assets/images/magangin_logo.png',
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 22,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Form Lamar Magang',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.border,
                backgroundImage:
                avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 20,
                )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // KARTU INFORMASI LOWONGAN
  Widget _buildJobCard() {
    final companyName =
        widget.job.company?.name ?? 'Perusahaan';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.business_outlined,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF1FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.job.category,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.button,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        widget.job.location,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  widget.job.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  companyName,
                  style: const TextStyle(
                    fontSize: 12,
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

  // KARTU PROFIL PELAMAR
  Widget _buildApplicantCard() {
    final avatarUrl = widget.profile.avatarUrl;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil Pelamar (Otomatis)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: AppColors.background,
                backgroundImage:
                avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 25,
                )
                    : null,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.profile.fullName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.profile.university ?? '-'}'
                          ' • ${widget.profile.major ?? '-'}',
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
        ],
      ),
    );
  }

  // JUDUL BAGIAN
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  // DROPDOWN CV
  Widget _buildCvDropdown(List<DocumentItem> cvs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle('Pilih CV'),
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        DropdownButtonFormField<String>(
          initialValue: _selectedCvId,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: cvs.isEmpty
                ? 'Belum ada CV'
                : 'Pilih dokumen CV',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.button,
                width: 1.5,
              ),
            ),
          ),
          items: cvs.map((document) {
            return DropdownMenuItem<String>(
              value: document.id,
              child: Text(
                document.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            );
          }).toList(),
          onChanged: cvs.isEmpty
              ? null
              : (value) {
            setState(() {
              _selectedCvId = value;
            });
          },
        ),
        const Padding(
          padding: EdgeInsets.only(left: 4, top: 7),
          child: Text(
            'Format PDF, maksimal 5 MB',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // PESAN UNTUK PERUSAHAAN
  Widget _buildMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Pesan untuk perusahaan'),
        const SizedBox(height: 9),
        TextField(
          controller: _messageController,
          maxLines: 4,
          maxLength: 500,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.primary,
          ),
          decoration: InputDecoration(
            hintText:
            'Ceritakan singkat ketertarikanmu pada posisi '
                '${widget.job.title} dan pengalaman relevan...',
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(15),
            counterStyle: const TextStyle(fontSize: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: AppColors.button,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // INFORMASI KHS
  Widget _buildKhsInformation() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EEFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD1DEFF),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school,
              color: AppColors.button,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KHS terlampir otomatis',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Transkrip nilai semester terakhir dari '
                      'universitas akan dikirim bersama '
                      'lamaranmu.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ITEM CHECKLIST DOKUMEN
  Widget _buildChecklistItem(String title, bool isAvailable) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isAvailable
                ? Icons.check_circle
                : Icons.info_outline,
            color: isAvailable
                ? AppColors.button
                : AppColors.textSecondary,
            size: 17,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // KELENGKAPAN DOKUMEN
  Widget _buildDocumentChecklist(List<DocumentItem> documents) {
    final hasCv = documents.any((doc) => doc.type == 'cv');

    final hasKhs = documents.any((doc) => doc.type == 'khs');

    final hasProposal = documents.any(
          (doc) => doc.type == 'internship_proposal',
    );

    final hasCoverLetter = documents.any(
          (doc) =>
      doc.type == 'internship_letter' ||
          doc.type == 'cover_letter',
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kelengkapan Dokumen',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 15),
          _buildChecklistItem('CV siap', hasCv),
          _buildChecklistItem('KHS siap', hasKhs),
          _buildChecklistItem('Proposal Magang siap', hasProposal),
          _buildChecklistItem(
            'Surat Pengantar Magang dari Kampus siap',
            hasCoverLetter,
          ),
        ],
      ),
    );
  }

  // PERSETUJUAN
  Widget _buildAgreement() {
    return InkWell(
      onTap: () {
        setState(() {
          _agreementAccepted = !_agreementAccepted;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25,
            height: 25,
            child: Checkbox(
              value: _agreementAccepted,
              onChanged: (value) {
                setState(() {
                  _agreementAccepted = value ?? false;
                });
              },
              activeColor: AppColors.button,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 3),
              child: Text(
                'Saya setuju data dan dokumen dibagikan '
                    'ke perusahaan.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TOMBOL KIRIM
  Widget _buildSubmitButton() {
    final canSubmit =
        _agreementAccepted &&
            _selectedCvId != null &&
            !_isSubmitting;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: canSubmit ? _submitApplication : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.button,
          disabledBackgroundColor: const Color(0xFFDDE3EB),
          foregroundColor: Colors.white,
          disabledForegroundColor: const Color(0xFF8793A5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
          width: 21,
          height: 21,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Kirim Lamaran',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 9),
            Icon(
              Icons.send_outlined,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }

  // TAMPILAN UTAMA
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FutureBuilder<List<DocumentItem>>(
              future: _documentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.button,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Gagal memuat dokumen: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final documents = snapshot.data ?? [];

                final cvs = documents
                    .where((doc) => doc.type == 'cv')
                    .toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    12,
                    12,
                    12,
                    20,
                  ),
                  children: [
                    _buildJobCard(),
                    const SizedBox(height: 16),
                    _buildApplicantCard(),
                    const SizedBox(height: 19),
                    _buildCvDropdown(cvs),
                    const SizedBox(height: 19),
                    _buildMessageSection(),
                    const SizedBox(height: 16),
                    _buildKhsInformation(),
                    const SizedBox(height: 16),
                    _buildDocumentChecklist(documents),
                    const SizedBox(height: 17),
                    _buildAgreement(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EFF8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: _buildSubmitButton(),
        ),
      ),
    );
  }
}
