
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/supabase_config.dart';
import '../../models/application.dart';
import '../../models/status_history.dart';
import '../interfaces/application_repository.dart';

class SupabaseApplicationRepository
    implements ApplicationRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  String get _userId {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    return user.id;
  }

  static const String _applicationSelect =
      '*, job:jobs(*, company:companies(*))';

  @override
  Future<Application> apply({
    required String jobId,
    required String cvDocumentId,
    String? coverLetterDocumentId,
    String? message,
  }) async {
    final userId = _userId;

    // 1. Periksa status verifikasi mahasiswa.
    final profile = await _client
        .from('profiles')
        .select('verification_status')
        .eq('id', userId)
        .maybeSingle();

    if (profile == null ||
        profile['verification_status'] != 'verified') {
      throw Exception(
        'Akun mahasiswa belum terverifikasi. '
            'Kamu belum dapat melamar magang.',
      );
    }

    // 2. Pastikan lowongan tersedia.
    final job = await _client
        .from('jobs')
        .select('id, status')
        .eq('id', jobId)
        .maybeSingle();

    if (job == null || job['status'] != 'open') {
      throw Exception('Lowongan tidak tersedia atau sudah ditutup.');
    }

    // 3. Pastikan CV milik mahasiswa dan bertipe CV.
    final cv = await _client
        .from('documents')
        .select('id')
        .eq('id', cvDocumentId)
        .eq('owner_id', userId)
        .eq('type', 'cv')
        .maybeSingle();

    if (cv == null) {
      throw Exception('CV tidak ditemukan atau bukan milikmu.');
    }

    // 4. Periksa cover letter jika disertakan.
    if (coverLetterDocumentId != null) {
      final coverLetter = await _client
          .from('documents')
          .select('id')
          .eq('id', coverLetterDocumentId)
          .eq('owner_id', userId)
          .eq('type', 'cover_letter')
          .maybeSingle();

      if (coverLetter == null) {
        throw Exception(
          'Cover letter tidak ditemukan atau bukan milikmu.',
        );
      }
    }

    // 5. Cari KHS terbaru milik mahasiswa.
    final khs = await _client
        .from('documents')
        .select('id')
        .eq('owner_id', userId)
        .eq('type', 'khs')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    // 6. Cegah mahasiswa melamar lowongan yang sama dua kali.
    final existingApplication = await _client
        .from('applications')
        .select('id')
        .eq('student_id', userId)
        .eq('job_id', jobId)
        .maybeSingle();

    if (existingApplication != null) {
      throw Exception(
        'Kamu sudah pernah mengirim lamaran untuk lowongan ini.',
      );
    }

    // 7. Simpan lamaran.
    final response = await _client
        .from('applications')
        .insert({
      'job_id': jobId,
      'student_id': userId,
      'cv_document_id': cvDocumentId,
      'khs_document_id': khs?['id'],
      'cover_letter_document_id': coverLetterDocumentId,
      'message': message,
      'status': 'sent',
    })
        .select(_applicationSelect)
        .single();

    final application = Application.fromJson(response);

    // 8. Catat status awal pada riwayat lamaran.
    await _client.from('application_status_history').insert({
      'application_id': application.id,
      'status': 'sent',
    });

    return application;
  }

  @override
  Future<List<Application>> getMyApplications() async {
    final response = await _client
        .from('applications')
        .select(_applicationSelect)
        .eq('student_id', _userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Application.fromJson(item))
        .toList();
  }

  @override
  Future<List<StatusHistory>> getHistory(
      String applicationId,
      ) async {
    final response = await _client
        .from('application_status_history')
        .select()
        .eq('application_id', applicationId)
        .order('changed_at', ascending: true);

    return (response as List)
        .map((item) => StatusHistory.fromJson(item))
        .toList();
  }

  @override
  Future<void> cancelApplication(String id) async {
    final userId = _userId;

    // Pastikan lamaran milik mahasiswa yang sedang login.
    final application = await _client
        .from('applications')
        .select('id, status')
        .eq('id', id)
        .eq('student_id', userId)
        .maybeSingle();

    if (application == null) {
      throw Exception('Lamaran tidak ditemukan.');
    }

    // Hanya lamaran dengan status sent yang boleh dibatalkan.
    if (application['status'] != 'sent') {
      throw Exception(
        'Lamaran hanya dapat dibatalkan ketika status masih sent.',
      );
    }

    await _client
        .from('applications')
        .update({
      'status': 'cancelled',
      'updated_at': DateTime.now().toIso8601String(),
    })
        .eq('id', id)
        .eq('student_id', userId);

    // Catat perubahan status.
    await _client.from('application_status_history').insert({
      'application_id': id,
      'status': 'cancelled',
    });
  }
}
