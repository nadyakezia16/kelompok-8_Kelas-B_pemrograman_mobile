
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/application.dart';
import '../../repositories/interfaces/application_repository.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() =>
      _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  late Future<List<Application>> _applicationsFuture;

  String _selectedStatus = 'all';

  static const List<_ApplicationFilter> _filters = [
    _ApplicationFilter('Semua', 'all'),
    _ApplicationFilter('Terkirim', 'sent'),
    _ApplicationFilter('Dilihat', 'viewed'),
    _ApplicationFilter('Diproses', 'processing'),
    _ApplicationFilter('Wawancara', 'interview'),
    _ApplicationFilter('Diterima', 'accepted'),
    _ApplicationFilter('Ditolak', 'rejected'),
    _ApplicationFilter('Dibatalkan', 'cancelled'),
  ];

  @override
  void initState() {
    super.initState();
    _applicationsFuture = _loadApplications();
  }

  Future<List<Application>> _loadApplications() {
    return context
        .read<ApplicationRepository>()
        .getMyApplications();
  }

  Future<void> _refreshApplications() async {
    setState(() {
      _applicationsFuture = _loadApplications();
    });

    await _applicationsFuture;
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
        return AppColors.success;
      case 'rejected':
      case 'cancelled':
        return AppColors.error;
      case 'interview':
        return const Color(0xFF9333EA);
      case 'processing':
        return AppColors.warning;
      case 'viewed':
        return const Color(0xFF3478D4);
      default:
        return AppColors.button;
    }
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

    final localDate = date.toLocal();

    return '${localDate.day} ${months[localDate.month - 1]} ${localDate.year}';
  }

  int _countStatus(
      List<Application> applications,
      String status,
      ) {
    if (status == 'all') {
      return applications.length;
    }

    return applications
        .where((application) => application.status == status)
        .length;
  }

  int _countActive(List<Application> applications) {
    return applications.where((application) {
      return application.status != 'rejected' &&
          application.status != 'cancelled';
    }).length;
  }

  List<Application> _filteredApplications(
      List<Application> applications,
      ) {
    if (_selectedStatus == 'all') {
      return applications;
    }

    return applications
        .where(
          (application) =>
      application.status == _selectedStatus,
    )
        .toList();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 0.7,
          ),
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/magangin_logo.png',
            width: 34,
            height: 34,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.school,
                color: AppColors.primary,
                size: 32,
              );
            },
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Text(
              'Lamaran',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              _showMessage('Belum ada notifikasi baru.');
            },
            icon: const Icon(
              Icons.notifications_none,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 5),
          const CircleAvatar(
            radius: 17,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: AppColors.primary,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageTitle(List<Application> applications) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lamaran Saya',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Pantau progres karirmu di sini',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE5EFFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 15,
                  color: AppColors.button,
                ),
                const SizedBox(width: 5),
                Text(
                  '${_countActive(applications)} Aktif',
                  style: const TextStyle(
                    color: AppColors.button,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(List<Application> applications) {
    return SizedBox(
      height: 43,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) =>
        const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = _selectedStatus == filter.value;
          final count = _countStatus(
            applications,
            filter.value,
          );

          return ChoiceChip(
            selected: selected,
            showCheckmark: false,
            label: Text(
              '${filter.label} ($count)',
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            selectedColor: AppColors.button,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected
                  ? AppColors.button
                  : AppColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onSelected: (value) {
              setState(() {
                _selectedStatus = filter.value;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required bool filtered,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 35,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: const BoxDecoration(
                color: Color(0xFFE5EFFF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                filtered
                    ? Icons.search_off
                    : Icons.description_outlined,
                size: 42,
                color: AppColors.button,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              filtered
                  ? 'Tidak Ada Lamaran'
                  : 'Belum Ada Lamaran',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filtered
                  ? 'Belum ada lamaran dengan status ini.'
                  : 'Kamu belum mengirim lamaran magang. Yuk, temukan kesempatan magang yang sesuai dengan minatmu!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.6,
              ),
            ),
            if (!filtered) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showMessage(
                      'Silakan buka menu Eksplorasi untuk mencari lowongan magang.',
                    );
                  },
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Cari Lowongan Magang'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == 'accepted'
                ? Icons.check_circle
                : status == 'rejected'
                ? Icons.cancel_outlined
                : status == 'interview'
                ? Icons.video_call_outlined
                : Icons.send_outlined,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            _statusLabel(status),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(Application application) {
    final job = application.job;
    final companyName = job?.company?.name ?? 'Perusahaan';
    final jobTitle = job?.title ?? 'Lowongan Magang';
    final location = job?.location ?? 'Lokasi tidak tersedia';
    final status = application.status;
    final canCancel = status == 'sent' ||
        status == 'viewed' ||
        status == 'processing';

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Text(
                  companyName.isNotEmpty
                      ? companyName[0].toUpperCase()
                      : 'M',
                  style: TextStyle(
                    color: _statusColor(status),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jobTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      companyName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Dikirim ${_formatDate(application.createdAt)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 11),
          Row(
            children: [
              if (canCancel) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmCancel(application),
                    icon: const Icon(
                      Icons.undo,
                      size: 15,
                    ),
                    label: const Text('Tarik Lamaran'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.border,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showApplicationDetail(application),
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 15,
                  ),
                  label: const Text('Lihat Detail'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 38),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    textStyle: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(Application application) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tarik Lamaran?'),
          content: const Text(
            'Apakah kamu yakin ingin menarik lamaran ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Ya, Tarik'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await context
          .read<ApplicationRepository>()
          .cancelApplication(application.id);

      if (!mounted) return;

      await _refreshApplications();
      _showMessage('Lamaran berhasil ditarik.');
    } catch (e) {
      _showMessage('Gagal menarik lamaran: $e');
    }
  }

  void _showApplicationDetail(Application application) {
    final job = application.job;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Detail Lamaran'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow(
                  'Posisi',
                  job?.title ?? 'Lowongan Magang',
                ),
                _detailRow(
                  'Perusahaan',
                  job?.company?.name ?? 'Tidak tersedia',
                ),
                _detailRow(
                  'Lokasi',
                  job?.location ?? 'Tidak tersedia',
                ),
                _detailRow(
                  'Status',
                  _statusLabel(application.status),
                ),
                _detailRow(
                  'Tanggal Lamaran',
                  _formatDate(application.createdAt),
                ),
                if (application.message != null &&
                    application.message!.isNotEmpty)
                  _detailRow(
                    'Pesan',
                    application.message!,
                  ),
                if (application.companyNote != null &&
                    application.companyNote!.isNotEmpty)
                  _detailRow(
                    'Catatan Perusahaan',
                    application.companyNote!,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<Application> applications) {
    final filtered = _filteredApplications(applications);

    return RefreshIndicator(
      onRefresh: _refreshApplications,
      child: filtered.isEmpty
          ? ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.40,
            child: _buildEmptyState(
              filtered: applications.isNotEmpty,
            ),
          ),
        ],
      )
          : ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(15, 12, 15, 20),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return _buildApplicationCard(filtered[index]);
        },
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
              child: FutureBuilder<List<Application>>(
                future: _applicationsFuture,
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
                              color: AppColors.error,
                              size: 42,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Gagal memuat lamaran.',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _refreshApplications,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final applications = snapshot.data ?? [];

                  return Column(
                    children: [
                      _buildPageTitle(applications),
                      _buildFilters(applications),
                      Expanded(
                        child: _buildContent(applications),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationFilter {
  final String label;
  final String value;

  const _ApplicationFilter(this.label, this.value);
}
