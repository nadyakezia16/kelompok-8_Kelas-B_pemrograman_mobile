
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config.dart';
import 'core/supabase/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/repository_providers.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase hanya jika mode Supabase aktif.
  await SupabaseConfig.initialize();

  runApp(const MaganginApp());
}

class MaganginApp extends StatelessWidget {
  const MaganginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: repositoryProviders,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
