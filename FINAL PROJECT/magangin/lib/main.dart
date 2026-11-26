
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/repository_providers.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

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
