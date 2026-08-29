import 'package:flutter/material.dart';
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
