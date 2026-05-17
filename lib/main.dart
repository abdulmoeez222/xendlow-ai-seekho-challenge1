import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config.dart' as app_config;
import 'providers/pipeline_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: app_config.Config.supabaseUrl,
    anonKey: app_config.Config.supabaseAnonKey,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => PipelineProvider(),
      child: InsightEngineApp(),
    ),
  );
}

class InsightEngineApp extends StatelessWidget {
  const InsightEngineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insight Engine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
