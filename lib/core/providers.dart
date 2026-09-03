import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/caption_design.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/projects_controller.dart';

final projectsProvider = ChangeNotifierProvider<ProjectsController>(
  (_) => ProjectsController(),
);
final pendingVideoProvider = StateProvider<XFile?>((_) => null);
final transcriptionProvider = StateProvider<Map<String, dynamic>?>((_) => null);

final captionDesignProvider = StateProvider<CaptionDesign>(
  (_) => const CaptionDesign(),
);
final captionRecentColorsProvider = StateProvider<List<Color>>(
  (_) => const [
    Colors.white,
    Color(0xFFFFD15C),
    Color(0xFF9FE870),
    Color(0xFFFF5C5C),
    Color(0xFF5C9CFF),
    Color(0xFFE870A0),
  ],
);

class CreditsNotifier extends StateNotifier<int> {
  CreditsNotifier() : super(60) {
    _load();
  }

  static const String _key = 'user_credits';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getInt(_key) ?? 60;
    } catch (_) {}
  }

  Future<bool> deductCredits(int amount) async {
    if (state < amount) return false;
    state = state - amount;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, state);
    } catch (_) {}
    return true;
  }

  Future<void> addCredits(int amount) async {
    state = state + amount;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, state);
    } catch (_) {}
  }
}

final creditsProvider = StateNotifierProvider<CreditsNotifier, int>(
  (_) => CreditsNotifier(),
);
