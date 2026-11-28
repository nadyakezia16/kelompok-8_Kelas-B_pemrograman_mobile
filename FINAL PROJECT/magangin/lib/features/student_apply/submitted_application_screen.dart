
import 'package:flutter/material.dart';

import '../../models/application.dart';
import '../../models/job.dart';
import 'applications_screen.dart';

class SubmittedApplicationScreen extends StatelessWidget {
  final Application application;
  final Job job;

  const SubmittedApplicationScreen({
    super.key,
    required this.application,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    final companyName = job.company?.name ?? 'Perusahaan';

    final location = job.location.isEmpty
        ? 'Lokasi tidak tersedia'
        : job.location;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF193451),
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 5),

                  Image.asset(
                    'assets/images/magangin_logo.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.school,
                        size: 34,
                        color: Color(0xFF193451),
                      );
                    },
                  ),

                  const SizedBox(width: 8),

                  const Expanded(
                    child: Text(
                      'Lamaran Terkirim',
                      style: TextStyle(
                        color: Color(0xFF193451),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFDCE6F5),
                    child: Icon(
                      Icons.person,
                      color: Color(0xFF49627D),
                      size: 23,
                    ),
                  ),
                ],
              ),
            ),

            // KONTEN UTAMA
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 95),

                    // IKON SUKSES
                    Container(
                      width: 124,
                      height: 124,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FF),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: const BoxDecoration(
                            color: Color(0xFF18A058),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 48,
                            weight: 3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // JUDUL
                    const Text(
                      'Lamaran terkirim!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF193451),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Pantau statusnya di menu Lamaran',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 27),

                    // KARTU LOWONGAN
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 17,
                        vertical: 17,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // LOGO PERUSAHAAN
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.business,
                              color: Color(0xFF347DD2),
                              size: 29,
                            ),
                          ),

                          const SizedBox(width: 14),

                          // INFORMASI LOWONGAN
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF193451),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  '$companyName • $location',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF718096),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // LABEL STATUS
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F0FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Baru saja',
                              style: TextStyle(
                                color: Color(0xFF347DD2),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 34),

                    // TOMBOL LIHAT LAMARAN
                    SizedBox(
                      width: double.infinity,
                      height: 53,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const ApplicationsScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF347DD2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Lihat Lamaran Saya',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 13),

                    // TOMBOL CARI MAGANG LAIN
                    SizedBox(
                      width: double.infinity,
                      height: 51,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE4EEFF),
                          foregroundColor: const Color(0xFF347DD2),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 20,
                            ),
                            SizedBox(width: 9),
                            Text(
                              'Cari Magang Lain',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
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
