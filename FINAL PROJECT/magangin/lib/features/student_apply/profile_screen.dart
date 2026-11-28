
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/profile.dart';
import '../../repositories/interfaces/auth_repository.dart';
import 'documents_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Profile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Profile?> _loadProfile() {
    return context.read<AuthRepository>().currentProfile();
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/magangin_logo.png',
            width: 42,
            height: 42,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Profil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur notifikasi belum tersedia.'),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
              size: 27,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Profile profile) {
    final String? avatarUrl = profile.avatarUrl;

    ImageProvider? imageProvider;

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith('http://') ||
          avatarUrl.startsWith('https://')) {
        // Foto dari Supabase atau URL online.
        imageProvider = NetworkImage(avatarUrl);
      } else if (avatarUrl.startsWith('mock/')) {
        // Path simulasi mock bukan path file yang bisa ditampilkan.
        imageProvider = null;
      } else {
        // Foto yang tersimpan di perangkat.
        imageProvider = FileImage(File(avatarUrl));
      }
    }

    return CircleAvatar(
      radius: 43,
      backgroundColor: AppColors.background,
      backgroundImage: imageProvider,
      onBackgroundImageError:
      imageProvider == null ? null : (_, _) {},
      child: imageProvider == null
          ? const Icon(
        Icons.person,
        size: 48,
        color: AppColors.primary,
      )
          : null,
    );
  }

  Widget _buildProfileCard(Profile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAvatar(profile),
          const SizedBox(height: 16),
          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profile.university?.isNotEmpty == true
                ? profile.university!
                : 'Universitas belum diisi',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            profile.major?.isNotEmpty == true
                ? profile.major!
                : 'Jurusan belum diisi',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isLogout
                      ? AppColors.error.withValues(alpha: 0.08)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isLogout
                      ? AppColors.error
                      : AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isLogout
                            ? AppColors.error
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Profile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileCard(profile),
          const SizedBox(height: 24),

          _buildMenuItem(
            icon: Icons.edit_outlined,
            title: 'Edit Profil',
            subtitle: 'Ubah informasi profil kamu',
            onTap: () async {
              final updatedProfile = await Navigator.push<Profile>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    profile: profile,
                  ),
                ),
              );

              if (updatedProfile != null && mounted) {
                setState(() {
                  _profileFuture = Future.value(updatedProfile);
                });
              }
            },
          ),

          const SizedBox(height: 12),

          _buildMenuItem(
            icon: Icons.description_outlined,
            title: 'Dokumen Saya',
            subtitle: 'Kelola dokumen persyaratan magang',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DocumentsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          _buildMenuItem(
            icon: Icons.logout_rounded,
            title: 'Keluar',
            subtitle: 'Keluar dari akun Magangin',
            isLogout: true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Fungsi keluar akan ditambahkan berikutnya.',
                  ),
                ),
              );
            },
          ),
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
              child: FutureBuilder<Profile?>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Gagal mengambil profil: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final profile = snapshot.data;

                  if (profile == null) {
                    return const Center(
                      child: Text(
                        'Profil pengguna tidak ditemukan.',
                      ),
                    );
                  }

                  return _buildContent(profile);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
