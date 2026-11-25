
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../repositories/interfaces/auth_repository.dart';
import 'placeholder_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',

  redirect: (context, state) async {
    final authRepository = context.read<AuthRepository>();

    final profile = await authRepository.currentProfile();
    final currentPath = state.matchedLocation;

    final isLoginPage = currentPath == '/login';
    final isRegisterPage = currentPath == '/register';

    // Pengguna belum login.
    if (profile == null) {
      if (isLoginPage || isRegisterPage) {
        return null;
      }

      return '/login';
    }

    // Tentukan halaman utama berdasarkan role.
    String homePath;

    switch (profile.role) {
      case 'student':
        homePath = '/home';
        break;
      case 'company':
        homePath = '/company-panel';
        break;
      case 'admin':
        homePath = '/admin';
        break;
      default:
        return '/login';
    }

    // Pengguna yang sudah login tidak perlu kembali ke login/register.
    if (isLoginPage ||
        isRegisterPage ||
        currentPath == '/') {
      return homePath;
    }

    // Pembatasan halaman berdasarkan role.
    if (profile.role == 'student') {
      if (currentPath == '/company-panel' ||
          currentPath == '/admin') {
        return '/home';
      }
    }

    if (profile.role == 'company') {
      if (currentPath == '/admin') {
        return '/company-panel';
      }

      if (_isStudentRoute(currentPath)) {
        return '/company-panel';
      }
    }

    if (profile.role == 'admin') {
      if (currentPath != '/admin' &&
          currentPath != '/notifications') {
        return '/admin';
      }
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/login',
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) =>
      const PlaceholderScreen(title: 'Login'),
    ),

    GoRoute(
      path: '/register',
      builder: (context, state) =>
      const PlaceholderScreen(title: 'Register'),
    ),

    GoRoute(
      path: '/home',
      builder: (context, state) =>
      const PlaceholderScreen(title: 'Beranda Mahasiswa'),
    ),

    GoRoute(
      path: '/explore',
      builder: (context, state) =>
      const PlaceholderScreen(title: 'Jelajahi Lowongan'),
    ),

    GoRoute(
      path: '/search',
      builder: (context, state) =>
      const PlaceholderScreen(title: 'Pencarian'),
    ),

    GoRoute(
      path: '/job/:id',
      builder: (context, state) => PlaceholderScreen(
        title: 'Detail Lowongan ${state.pathParameters['id']}',
      ),
    ),

    GoRoute(
      path: '/company/:id',
      builder: (context, state) => PlaceholderScreen(
        title: 'Detail Perusahaan ${state.pathParameters['id']}',
      ),
    ),

    GoRoute(
      path: '/saved',
      builder: (context, state) =>
      const PlaceholderScreen(title: 'Lowongan Tersimpan'),
    ),

    GoRoute(
      path: '/preferences',
      builder: (context, state) =>
      const PlaceholderScreen(title: 'Preferensi'),
    ),

    GoRoute(
      path: '/documents',
      builder: (context, state) =>
      const PlaceholderScreen(title: 'Dokumen'),
    ),

    GoRoute(
      path: '/apply/:jobId',
      builder: (context, state) => PlaceholderScreen(
        title: 'Formulir Lamaran ${state.pathParameters['jobId']}',
      ),
    ),

    GoRoute(
      path: '/applications',
      builder: (context, state) =>
      const PlaceholderScreen(title: 'Lamaran Saya'),
    ),

    GoRoute(
      path: '/profile',
      builder: (context, state) =>
      const PlaceholderScreen(title: 'Profil'),
    ),

    GoRoute(
      path: '/edit-profile',
      builder: (context, state) =>
      const PlaceholderScreen(title: 'Edit Profil'),
    ),

    GoRoute(
      path: '/notifications',
      builder: (context, state) =>
      const PlaceholderScreen(title: 'Notifikasi'),
    ),

    GoRoute(
      path: '/company-panel',
      builder: (context, state) =>
      const PlaceholderScreen(title: 'Panel Perusahaan'),
    ),

    GoRoute(
      path: '/admin',
      builder: (context, state) =>
      const PlaceholderScreen(title: 'Panel Admin'),
    ),
  ],

  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Halaman tidak ditemukan: ${state.error}',
      ),
    ),
  ),
);

bool _isStudentRoute(String path) {
  const studentRoutes = [
    '/home',
    '/explore',
    '/search',
    '/saved',
    '/preferences',
    '/documents',
    '/applications',
    '/profile',
    '/edit-profile',
  ];

  return studentRoutes.contains(path) ||
      path.startsWith('/job/') ||
      path.startsWith('/company/') ||
      path.startsWith('/apply/');
}
