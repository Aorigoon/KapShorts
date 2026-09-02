import 'dart:convert';

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:file_picker/file_picker.dart';
import 'package:cross_file/cross_file.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'core/services/worker_transcription_service.dart';
import 'core/app_colors.dart';
import 'core/models/caption_design.dart';
import 'screens/editor_screen.dart';
import 'screens/home_screen.dart';
import 'screens/export_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/transcribing_screen.dart';
import 'core/models/video_project.dart';
import 'core/controllers/projects_controller.dart';
import 'core/providers.dart';
import 'core/utils.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ProviderScope(child: SubReelApp()));
}



class NoScrollbarBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class SubReelApp extends StatelessWidget {
  const SubReelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseText = GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme);
    return MaterialApp.router(
      title: 'SubReel',
      scrollBehavior: NoScrollbarBehavior(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.canvas,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
          onPrimary: Colors.black,
          onSurface: AppColors.primary,
        ),
        textTheme: baseText.apply(
          bodyColor: AppColors.primary,
          displayColor: AppColors.primary,
        ),
        splashFactory: NoSplash.splashFactory,
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
    GoRoute(path: '/projects', builder: (_, _) => const ProjectsScreen()),
    GoRoute(
      path: '/transcribing',
      builder: (_, _) => const TranscribingScreen(),
    ),
    GoRoute(path: '/editor', builder: (_, _) => const EditorScreen()),
    GoRoute(path: '/export', builder: (_, _) => const ExportScreen()),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
  ],
);




final captionDesignProvider = StateProvider<CaptionDesign>(
  (_) => const CaptionDesign(),
);

final captionRecentColorsProvider = StateProvider<List<Color>>(
  (_) => const [
    Colors.white,
    Color(0xFFFFD15C),
    Color(0xFF9FE870),
    Color(0xFFFF5C5C),
  ],
);


