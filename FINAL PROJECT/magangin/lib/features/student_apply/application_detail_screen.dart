
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/application.dart';
import '../../models/job.dart';
import '../../models/document_item.dart';
import '../../models/status_history.dart';
import '../../repositories/interfaces/application_repository.dart';
import '../../repositories/interfaces/document_repository.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final Application application;
  final Job job;

  const ApplicationDetailScreen({
    super.key,
    required this.application,
    required this.job,
  });

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState
    extends State<ApplicationDetailScreen> {
  static const Color primary = Color(0xFF193451);
  static const Color blue = Color(0xFF347DD2);
  static const Color background = Color(0xFFF0F4FF);
  static const Color secondary = Color(0xFF718096);

  late Future<List<StatusHistory>> _historyFuture;
  late Future<List<DocumentItem>> _documentsFuture;

  String? _statusOverride;
  bool _isCancelling = false;

  String get currentStatus =>
      _statusOverride ?? widget.application.status;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _historyFuture = context
        .read<ApplicationRepository>()
        .getHistory(widget.application.id);

    _documentsFuture = context
        .read<DocumentRepository>()
        .listMyDocuments();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];

    final local = date.toLocal();

    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'sent':
        return 'Terkirim';
      case 'viewed':
        return 'Dilihat';
      case 'processing':
        return 'Diproses';
      case 'interview':
        return 'Wawancara';
      case 'accepted':
        return 'Diterima';
      case 'rejected':
        return 'Ditolak';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return const Color(0xFF18A058);
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFD64545);
      case 'processing':
        return const Color(0xFFB66A32);
      case 'interview':
        return const Color(0xFF9333EA);
      default:
        return blue;
    }
  }

  Future<void> _cancelApplication() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Batalkan Lamaran?'),
          content: const Text(
            'Apakah kamu yakin ingin membatalkan lamaran ini?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Kembali'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isCancelling = true);

    try {
      await context
          .read<ApplicationRepository>()
          .cancelApplication(widget.application.id);

      if (!mounted) return;

      setState(() {
        _statusOverride = 'cancelled';
        _historyFuture = context
            .read<ApplicationRepository>()
            .getHistory(widget.application.id);
        _isCancelling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lamaran berhasil dibatalkan.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isCancelling = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membatalkan lamaran: $e'),
        ),
      );
    }
  }

  Future<void> _showDocument(DocumentItem document) async {
    try {
      final url = await context
          .read<DocumentRepository>()
          .getSignedUrl(document.id);

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Dokumen Terlampir'),
            content: SelectableText('Link dokumen:\n$url'),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext),
                child: const Text('Tutup'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: url),
                  );
                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link dokumen disalin.'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Salin Link'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil dokumen: $e'),
        ),
      );
    }
  }

  Future<void> _showStatusSimulation() async {
    const statuses = [
      'sent',
      'viewed',
      'processing',
      'interview',
      'accepted',
      'rejected',
    ];

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Simulasi Perubahan Status',
                  style: TextStyle(
                    color: primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...statuses.map(
                    (status) => ListTile(
                  leading: Icon(
                    Icons.circle,
                    color: _statusColor(status),
                    size: 12,
                  ),
                  title: Text(_statusLabel(status)),
                  onTap: () =>
                      Navigator.pop(context, status),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _statusOverride = selected;
      });
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: primary,
              size: 25,
            ),
          ),
          Image.asset(
            'assets/images/magangin_logo.png',
            width: 38,
            height: 38,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.school,
                color: primary,
                size: 32,
              );
            },
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Detail Lamaran',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFDCE6F5),
            child: Icon(
              Icons.person,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard() {
    final company = widget.job.company?.name ?? 'Perusahaan';

    final location = widget.job.location.isEmpty
        ? 'Lokasi tidak tersedia'
        : widget.job.location;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business,
                  color: blue,
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.title,
                      style: const TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company,
                      style: const TextStyle(
                        color: secondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F0FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 7,
                      color: _statusColor(currentStatus),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _statusLabel(currentStatus),
                      style: const TextStyle(
                        color: blue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _infoChip(
                  Icons.location_on_outlined,
                  location,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _infoChip(
                  Icons.work_outline,
                  widget.job.workType,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _infoChip(
                  Icons.access_time,
                  '${widget.job.durationMonths} Bulan',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 13,
            color: primary,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: primary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EEFF),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 19,
            backgroundColor: blue,
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              currentStatus == 'cancelled'
                  ? 'Lamaran ini telah dibatalkan.'
                  : 'Lamaranmu sudah mendarat di meja HRD! '
                  'Tetap semangat dan pantau terus perkembangannya.',
              style: const TextStyle(
                color: primary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timelineDescription(String status) {
    switch (status) {
      case 'sent':
        return 'Lamaran dan dokumen berhasil dikirim ke perusahaan.';
      case 'viewed':
        return 'Tim rekrutmen meninjau profil dan portofoliomu.';
      case 'processing':
        return 'Kualifikasi sedang dicocokkan dengan kebutuhan tim.';
      case 'interview':
        return 'Sesi perkenalan dan diskusi bersama User & HR.';
      case 'accepted':
        return 'Selamat! Surat penawaran magang resmi akan dikirimkan.';
      case 'rejected':
        return 'Lamaran belum berhasil pada kesempatan ini.';
      case 'cancelled':
        return 'Lamaran telah dibatalkan.';
      default:
        return '';
    }
  }

  Widget _buildTimeline(List<StatusHistory> histories) {
    const stages = [
      ('sent', 'Terkirim', Icons.send),
      ('viewed', 'Dilihat', Icons.visibility_outlined),
      ('processing', 'Diproses', Icons.hourglass_top),
      ('interview', 'Wawancara', Icons.groups_outlined),
      ('accepted', 'Diterima', Icons.celebration_outlined),
    ];

    final historyMap = <String, StatusHistory>{};

    for (final item in histories) {
      historyMap[item.status] = item;
    }

    const progress = {
      'sent': 0,
      'viewed': 1,
      'processing': 2,
      'interview': 3,
      'accepted': 4,
      'rejected': 2,
    };

    final currentIndex = progress[currentStatus];

    // Terkirim selalu aktif karena lamaran sudah dikirim.
    historyMap.putIfAbsent(
      'sent',
          () => StatusHistory(
        id: 'local-sent',
        applicationId: widget.application.id,
        status: 'sent',
        changedAt: widget.application.createdAt,
      ),
    );

    // Aktifkan semua tahapan sebelumnya sesuai status simulasi.
    if (currentIndex != null) {
      for (int i = 1; i <= currentIndex; i++) {
        final status = stages[i].$1;

        historyMap.putIfAbsent(
          status,
              () => StatusHistory(
            id: 'local-$status',
            applicationId: widget.application.id,
            status: status,
            changedAt: widget.application.createdAt,
          ),
        );
      }
    }

    // Status akhir Ditolak atau Dibatalkan.
    if (currentStatus == 'rejected' ||
        currentStatus == 'cancelled') {
      historyMap[currentStatus] = StatusHistory(
        id: 'local-$currentStatus',
        applicationId: widget.application.id,
        status: currentStatus,
        changedAt: DateTime.now(),
      );
    }

    final visibleStages = [
      ...stages,
      if (currentStatus == 'rejected')
        ('rejected', 'Ditolak', Icons.cancel_outlined),
      if (currentStatus == 'cancelled')
        ('cancelled', 'Dibatalkan', Icons.block),
    ];

    final latestDate = historyMap.values
        .map((item) => item.changedAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Riwayat Status',
                  style: TextStyle(
                    color: primary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text(
                'Diperbarui ',
                style: TextStyle(
                  color: secondary,
                  fontSize: 10,
                ),
              ),
              Text(
                _formatDate(latestDate),
                style: const TextStyle(
                  color: secondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(visibleStages.length, (index) {
            final stage = visibleStages[index];
            final history = historyMap[stage.$1];
            final isLast = index == visibleStages.length - 1;
            final isActive = history != null;
            final color = _statusColor(stage.$1);

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 34,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: isActive
                              ? color
                              : const Color(0xFFF0F2FA),
                          child: Icon(
                            stage.$3,
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF9AA5B5),
                            size: 16,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: const Color(0xFFE7EAF2),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 19),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  stage.$2,
                                  style: TextStyle(
                                    color: isActive
                                        ? primary
                                        : secondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                isActive
                                    ? _formatDate(history.changedAt)
                                    : 'Menunggu',
                                style: const TextStyle(
                                  color: secondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _timelineDescription(stage.$1),
                            style: const TextStyle(
                              color: secondary,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDocuments(List<DocumentItem> documents) {
    final documentIds = [
      widget.application.cvDocumentId,
      widget.application.khsDocumentId,
      widget.application.coverLetterDocumentId,
    ].whereType<String>().toSet();

    final attached = documents
        .where((document) => documentIds.contains(document.id))
        .toList();

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dokumen Terlampir',
            style: TextStyle(
              color: primary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          if (attached.isEmpty)
            const Text(
              'Informasi dokumen terlampir tidak tersedia.',
              style: TextStyle(
                color: secondary,
                fontSize: 12,
              ),
            )
          else
            ...attached.map(_buildDocumentItem),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(DocumentItem document) {
    final isCv = document.id == widget.application.cvDocumentId;

    final fileName = document.name.toLowerCase().endsWith('.pdf')
        ? document.name
        : '${document.name}.pdf';

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2FF),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: isCv
                  ? const Color(0xFFFFE1E1)
                  : const Color(0xFFE0EDFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCv
                  ? Icons.picture_as_pdf
                  : Icons.description_outlined,
              color: isCv
                  ? const Color(0xFFD64545)
                  : blue,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Diunggah ${_formatDate(document.createdAt)}',
                  style: const TextStyle(
                    color: secondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showDocument(document),
            icon: const Icon(
              Icons.visibility_outlined,
              color: blue,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    if (currentStatus != 'sent') {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: 49,
      child: ElevatedButton.icon(
        onPressed: _isCancelling ? null : _cancelApplication,
        icon: const Icon(Icons.close, size: 18),
        label: Text(
          _isCancelling
              ? 'Membatalkan...'
              : 'Batalkan Lamaran',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFCE5E5),
          foregroundColor: const Color(0xFFB42323),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }

  Widget _buildSimulationButton() {
    return TextButton.icon(
      onPressed: _showStatusSimulation,
      icon: const Icon(
        Icons.science_outlined,
        size: 16,
      ),
      label: const Text('Simulasi: ubah status'),
      style: TextButton.styleFrom(
        foregroundColor: secondary,
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  17,
                  8,
                  17,
                  22,
                ),
                child: Column(
                  children: [
                    _buildJobCard(),
                    const SizedBox(height: 16),
                    _buildMessageCard(),
                    const SizedBox(height: 16),
                    FutureBuilder<List<StatusHistory>>(
                      future: _historyFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text(
                            'Riwayat status gagal dimuat.',
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          );
                        }

                        return _buildTimeline(
                          snapshot.data ?? [],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<DocumentItem>>(
                      future: _documentsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text(
                            'Dokumen gagal dimuat.',
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          );
                        }

                        return _buildDocuments(
                          snapshot.data ?? [],
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    _buildCancelButton(),
                    const SizedBox(height: 4),
                    _buildSimulationButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
