import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../core/app_colors.dart';
import '../core/models/video_project.dart';
import '../core/models/caption_design.dart';
import '../core/providers.dart';
import '../core/utils.dart';
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final ValueNotifier<PlaybackInfo> _playback = ValueNotifier(
    const PlaybackInfo(),
  );
  final ValueNotifier<Duration?> _timelineSeek = ValueNotifier(null);
  final ValueNotifier<bool?> _playbackCommand = ValueNotifier(null);
  final ValueNotifier<double> _playbackSpeed = ValueNotifier(1.0);
  final ValueNotifier<PreviewAspect> _previewAspect = ValueNotifier(
    PreviewAspect.original,
  );
  String? _loadedProjectId;

  @override
  void dispose() {
    _playback.dispose();
    _timelineSeek.dispose();
    _playbackCommand.dispose();
    _playbackSpeed.dispose();
    _previewAspect.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final project = ref.watch(projectsProvider).selected;
    final transcription = ref.watch(transcriptionProvider);
    final design = ref.watch(captionDesignProvider);
    if (project != null && _loadedProjectId != project.id) {
      _loadedProjectId = project.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(captionDesignProvider.notifier).state =
              CaptionDesign.fromTemplate(project.template);
          _previewAspect.value = PreviewAspect.original;
        }
      });
    }
    final sidebarTapHandler = (EditorTool tool) {
      if (tool == EditorTool.style) {
        showCustomizeSheet(context, ref);
        return;
      }
      if (tool == EditorTool.addText) {
        showCaptionTextEditor(
          context,
          project?.videoPath ?? '',
          transcription ?? project?.transcription,
        );
        return;
      }
      if (tool == EditorTool.aspectRatio) {
        showAspectRatioSheet(context, _previewAspect);
        return;
      }
      showEditorToolSheet(
        context,
        ref,
        tool,
        transcription ?? project?.transcription,
      );
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: SizedBox(
                height: 42,
                child: Row(
                  children: [
                    if (isMobile)
                      _VideoOverlayIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => context.go('/'),
                      ),
                    const Spacer(),
                    Material(
                      color: Colors.white.withValues(alpha: .09),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () =>
                            showAppMessage(context, 'No edit to undo yet.'),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 78,
                          height: 38,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .18),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 38,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: SvgPicture.asset(
                                    'assets/icons/reply_arrow.svg',
                                    colorFilter: ColorFilter.mode(
                                      Colors.white.withValues(alpha: .9),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 18,
                                color: Colors.white.withValues(alpha: .14),
                              ),
                              SizedBox(
                                width: 38,
                                child: Transform.scale(
                                  scaleX: -1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: SvgPicture.asset(
                                      'assets/icons/reply_arrow.svg',
                                      colorFilter: ColorFilter.mode(
                                        Colors.white.withValues(alpha: .9),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 38,
                      child: FilledButton(
                        onPressed: () => context.go('/export'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(92, 38),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Export',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isMobile)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _EditorFloatingSidebar(onTap: sidebarTapHandler),
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: VideoPreviewPlayer(
                            videoPath: project?.videoPath ?? '',
                            transcription: transcription ?? project?.transcription,
                            design: design,
                            playback: _playback,
                            timelineSeek: _timelineSeek,
                            playbackCommand: _playbackCommand,
                            playbackSpeed: _playbackSpeed,
                            previewAspect: _previewAspect,
                            onReplaceVideo: () => replaceVideoForProject(context, ref),
                          ),
                        ),
                        _PreviewSimpleControls(
                          playback: _playback,
                          playbackSpeed: _playbackSpeed,
                          onPlayPause: () =>
                              _playbackCommand.value = !_playback.value.isPlaying,
                          onPrevious: () => _timelineSeek.value = Duration(
                            milliseconds: (_playback.value.position.inMilliseconds - 2000)
                                .clamp(0, _playback.value.duration.inMilliseconds)
                                .toInt(),
                          ),
                          onNext: () => _timelineSeek.value = Duration(
                            milliseconds: (_playback.value.position.inMilliseconds + 2000)
                                .clamp(0, _playback.value.duration.inMilliseconds)
                                .toInt(),
                          ),
                          onFullscreen: () => showFullscreenPreview(
                            context,
                            project?.videoPath ?? '',
                            transcription ?? project?.transcription,
                            design,
                          ),
                          onSpeed: () => showPlaybackSpeedSheet(context, _playbackSpeed),
                        ),
                        SizedBox(
                          height: 104,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                            child: CaptionTimeline(
                              transcription: transcription ?? project?.transcription,
                              playback: _playback,
                              onSeek: (position) => _timelineSeek.value = position,
                              videoPath: project?.videoPath ?? '',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isMobile) ...[
              const SizedBox(height: 4),
              EditorToolRail(onTap: sidebarTapHandler),
            ],
          ],
        ),
      ),
    );
  }
}

class _PreviewSimpleControls extends StatelessWidget {
  const _PreviewSimpleControls({
    required this.playback,
    required this.playbackSpeed,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
    required this.onFullscreen,
    required this.onSpeed,
  });
  final ValueNotifier<PlaybackInfo> playback;
  final ValueNotifier<double> playbackSpeed;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onFullscreen;
  final VoidCallback onSpeed;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<PlaybackInfo>(
    valueListenable: playback,
    builder: (_, state, _) => ValueListenableBuilder<double>(
      valueListenable: playbackSpeed,
      builder: (_, speed, _) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 1, 12, 1),
        child: Row(
          children: [
            SizedBox(
              width: 84,
              child: Text(
                '${_formatPlaybackTime(state.position)} / ${_formatPlaybackTime(state.duration)}',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
            if (MediaQuery.of(context).size.width >= 600)
              IconButton(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: Colors.white,
                iconSize: 24,
              ),
            IconButton(
              onPressed: onPrevious,
              icon: const Icon(Icons.skip_previous_rounded),
              color: Colors.white,
              iconSize: 24,
            ),
            IconButton(
              onPressed: onPlayPause,
              icon: Icon(
                state.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
              ),
              color: Colors.white,
              iconSize: 30,
            ),
            IconButton(
              onPressed: onNext,
              icon: const Icon(Icons.skip_next_rounded),
              color: Colors.white,
              iconSize: 24,
            ),
            const Spacer(),
            TextButton(
              onPressed: onSpeed,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: const Size(42, 36),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: Text(
                '${speed.toStringAsFixed(speed == speed.roundToDouble() ? 0 : 2)}×',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              onPressed: onFullscreen,
              icon: const Icon(Icons.fullscreen_rounded),
              color: Colors.white,
              iconSize: 22,
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showPlaybackSpeedSheet(
  BuildContext context,
  ValueNotifier<double> playbackSpeed,
) async {
  const rates = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: ValueListenableBuilder<double>(
          valueListenable: playbackSpeed,
          builder: (_, selectedRate, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.tertiary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Playback speed',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Changes the editor preview speed.',
                style: TextStyle(color: AppColors.secondary, fontSize: 12),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final rate in rates)
                    ChoiceChip(
                      label: Text(
                        '${rate.toStringAsFixed(rate == rate.roundToDouble() ? 0 : 2)}×',
                      ),
                      selected: selectedRate == rate,
                      selectedColor: Colors.white,
                      backgroundColor: AppColors.elevated,
                      labelStyle: TextStyle(
                        color: selectedRate == rate
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      side: BorderSide(
                        color: selectedRate == rate
                            ? Colors.white
                            : AppColors.line,
                      ),
                      onSelected: (_) {
                        playbackSpeed.value = rate;
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

enum PreviewAspect { original, portrait, square, landscape, classic, full }

extension PreviewAspectDetails on PreviewAspect {
  String get label => switch (this) {
    PreviewAspect.original => 'Original',
    PreviewAspect.portrait => '9:16',
    PreviewAspect.square => '1:1',
    PreviewAspect.landscape => '16:9',
    PreviewAspect.classic => '4:3',
    PreviewAspect.full => 'Full',
  };

  IconData get icon => switch (this) {
    PreviewAspect.original => Icons.crop_free_rounded,
    PreviewAspect.portrait => Icons.music_note_rounded,
    PreviewAspect.square => Icons.crop_square_rounded,
    PreviewAspect.landscape => Icons.smart_display_rounded,
    PreviewAspect.classic => Icons.video_settings_rounded,
    PreviewAspect.full => Icons.fullscreen_rounded,
  };

  double? get ratio => switch (this) {
    PreviewAspect.portrait => 9 / 16,
    PreviewAspect.square => 1,
    PreviewAspect.landscape => 16 / 9,
    PreviewAspect.classic => 4 / 3,
    PreviewAspect.original || PreviewAspect.full => null,
  };

  Size get selectorFrameSize => switch (this) {
    PreviewAspect.original => const Size(34, 46),
    PreviewAspect.portrait => const Size(25, 49),
    PreviewAspect.square => const Size(39, 39),
    PreviewAspect.landscape => const Size(50, 36),
    PreviewAspect.classic => const Size(45, 34),
    PreviewAspect.full => const Size(51, 40),
  };
}

Future<void> showAspectRatioSheet(
  BuildContext context,
  ValueNotifier<PreviewAspect> previewAspect,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: ValueListenableBuilder<PreviewAspect>(
          valueListenable: previewAspect,
          builder: (_, selected, _) {
            final selectedSize = selected.ratio == null
                ? const Size(92, 68)
                : selected.ratio! >= 1
                ? const Size(104, 62)
                : const Size(62, 104);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.tertiary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.crop_free_rounded, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Canvas & aspect',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Choose the format that fits your audience.',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.secondary,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF20282A), Color(0xFF131516)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 132,
                        height: 116,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .18),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: selectedSize.width,
                          height: selectedSize.height,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .12),
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            selected.icon,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected format',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              selected.label,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              switch (selected) {
                                PreviewAspect.portrait =>
                                  'Best for Reels, Shorts & TikTok',
                                PreviewAspect.square =>
                                  'Balanced for social feeds',
                                PreviewAspect.landscape =>
                                  'Best for YouTube & widescreen',
                                PreviewAspect.classic =>
                                  'Classic video framing',
                                PreviewAspect.original =>
                                  'Keep your source framing',
                                PreviewAspect.full =>
                                  'Fill the available canvas',
                              },
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Choose a format',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: PreviewAspect.values.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.12,
                  ),
                  itemBuilder: (_, index) {
                    final option = PreviewAspect.values[index];
                    final active = option == selected;
                    return InkWell(
                      onTap: () => previewAspect.value = option,
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white.withValues(alpha: .12)
                              : AppColors.elevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: active ? Colors.white : AppColors.line,
                            width: active ? 1.8 : 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: option.selectorFrameSize.width,
                                    height: option.selectorFrameSize.height,
                                    decoration: BoxDecoration(
                                      color: active
                                          ? Colors.white.withValues(alpha: .14)
                                          : Colors.black.withValues(alpha: .16),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: active
                                            ? Colors.white
                                            : AppColors.secondary,
                                      ),
                                    ),
                                    child: Icon(
                                      option.icon,
                                      size: 16,
                                      color: active
                                          ? Colors.white
                                          : AppColors.secondary,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    option.label,
                                    style: TextStyle(
                                      color: active
                                          ? Colors.white
                                          : AppColors.secondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (active)
                              const Positioned(
                                top: 0,
                                right: 0,
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  size: 17,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Use ${selected.label}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

class PlaybackInfo {
  const PlaybackInfo({
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
  });
  final Duration position;
  final Duration duration;
  final bool isPlaying;
}

class CaptionTimeline extends StatefulWidget {
  const CaptionTimeline({
    required this.transcription,
    required this.playback,
    required this.onSeek,
    required this.videoPath,
    super.key,
  });
  final Map<String, dynamic>? transcription;
  final ValueNotifier<PlaybackInfo> playback;
  final ValueChanged<Duration> onSeek;
  final String videoPath;

  @override
  State<CaptionTimeline> createState() => _CaptionTimelineState();
}

class _CaptionTimelineState extends State<CaptionTimeline> {
  static const _pixelsPerSecond = 52.0;
  late final ScrollController _scrollController;
  bool _isAutoFollowing = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    widget.playback.addListener(_followPlayhead);
  }

  @override
  void dispose() {
    widget.playback.removeListener(_followPlayhead);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _followPlayhead() async {
    if (!mounted || !_scrollController.hasClients || _isAutoFollowing) return;
    final playback = widget.playback.value;
    if (!playback.isPlaying) return;
    final target = playback.position.inMilliseconds / 1000 * _pixelsPerSecond;
    final safeTarget = target.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    if ((_scrollController.offset - safeTarget).abs() < 7) return;
    _isAutoFollowing = true;
    try {
      await _scrollController.animateTo(
        safeTarget,
        duration: const Duration(milliseconds: 110),
        curve: Curves.linear,
      );
    } finally {
      _isAutoFollowing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final raw = widget.transcription?['segments'];
    final segments = raw is List ? raw.whereType<Map>().toList() : <Map>[];
    return ValueListenableBuilder<PlaybackInfo>(
      valueListenable: widget.playback,
      builder: (_, state, _) {
        final currentSeconds = state.position.inMilliseconds / 1000;
        final totalSeconds = state.duration.inMilliseconds == 0
            ? 1
            : ((state.duration.inMilliseconds + 999) ~/ 1000);
        const pixelsPerSecond = _pixelsPerSecond;
        return LayoutBuilder(
          builder: (_, constraints) {
            if (state.duration == Duration.zero) {
              return const _TimelineLoadingRail();
            }
            final naturalWidth = totalSeconds * pixelsPerSecond;
            final sidePadding = constraints.maxWidth / 2;
            final timelineWidth = naturalWidth + (sidePadding * 2);
            return Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: timelineWidth,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: sidePadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _TimelineSecondsRuler(
                            totalSeconds: totalSeconds,
                            pixelsPerSecond: pixelsPerSecond,
                          ),
                          const SizedBox(height: 2),
                          SizedBox(
                            height: 46,
                            child: _VideoReel(
                              videoPath: widget.videoPath,
                              totalSeconds: totalSeconds,
                              pixelsPerSecond: pixelsPerSecond,
                              onSeek: widget.onSeek,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _TimelineCaptionRow(
                            segments: segments,
                            currentSeconds: currentSeconds,
                            pixelsPerSecond: pixelsPerSecond,
                            onSeek: widget.onSeek,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: (constraints.maxWidth / 2) - 1,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Container(width: 2, color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _TimelineLoadingRail extends StatelessWidget {
  const _TimelineLoadingRail();

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 14),
          Container(height: 46, color: const Color(0xFF151515)),
          const SizedBox(height: 4),
          Container(height: 30, color: const Color(0xFF1B1B1B)),
        ],
      ),
      const Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 2,
          height: double.infinity,
          child: ColoredBox(color: Colors.white),
        ),
      ),
    ],
  );
}

class _VideoReel extends StatelessWidget {
  const _VideoReel({
    required this.videoPath,
    required this.totalSeconds,
    required this.pixelsPerSecond,
    required this.onSeek,
  });
  final String videoPath;
  final ValueChanged<Duration> onSeek;
  final int totalSeconds;
  final double pixelsPerSecond;

  @override
  Widget build(BuildContext context) {
    final frameStep = totalSeconds > 60
        ? 5
        : totalSeconds > 30
        ? 4
        : totalSeconds > 15
        ? 2
        : 1;
    return FutureBuilder<File?>(
      future: createReelFrame(videoPath, 500),
      builder: (_, coverSnapshot) => Row(
        children: [
          for (var second = 0; second < totalSeconds; second += frameStep)
            _VideoReelThumbnail(
              key: ValueKey('$videoPath-$second'),
              videoPath: videoPath,
              timeMs: second * 1000,
              width:
                  ((totalSeconds - second) < frameStep
                      ? totalSeconds - second
                      : frameStep) *
                  pixelsPerSecond,
              fallback: coverSnapshot.data,
              onTap: () => onSeek(Duration(seconds: second)),
            ),
        ],
      ),
    );
  }
}

class _TimelineCaptionRow extends StatelessWidget {
  const _TimelineCaptionRow({
    required this.segments,
    required this.currentSeconds,
    required this.pixelsPerSecond,
    required this.onSeek,
  });
  final List<Map> segments;
  final double currentSeconds;
  final double pixelsPerSecond;
  final ValueChanged<Duration> onSeek;

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) {
      return SizedBox(
        height: 30,
        child: Container(
          width: 118,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xFFC86E16),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'Add captions',
            style: TextStyle(
              fontSize: 9,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 30,
      child: Stack(
        children: [
          for (final segment in segments)
            Builder(
              builder: (_) {
                final text = segment['text'] as String? ?? 'Caption';
                final start = (segment['start'] as num?)?.toDouble() ?? 0;
                final end = (segment['end'] as num?)?.toDouble() ?? start + 1;
                final active = currentSeconds >= start && currentSeconds <= end;
                return Positioned(
                  left: start * pixelsPerSecond,
                  width: ((end - start) * pixelsPerSecond - 3).clamp(
                    32.0,
                    double.infinity,
                  ),
                  top: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: () =>
                        onSeek(Duration(milliseconds: (start * 1000).round())),
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFFFFA62B)
                            : const Color(0xFFC86E16),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: active ? Colors.white : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _TimelineSecondsRuler extends StatelessWidget {
  const _TimelineSecondsRuler({
    required this.totalSeconds,
    required this.pixelsPerSecond,
  });
  final int totalSeconds;
  final double pixelsPerSecond;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 14,
    child: Row(
      children: List.generate(totalSeconds + 1, (second) {
        final markerEvery = totalSeconds >= 45 ? 5 : 4;
        final showLabel =
            second == 0 || second == totalSeconds || second % markerEvery == 0;
        return SizedBox(
          width: pixelsPerSecond,
          child: showLabel
              ? Text(
                  _label(Duration(seconds: second)),
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.secondary,
                  ),
                )
              : null,
        );
      }),
    ),
  );

  String _label(Duration value) =>
      '${value.inMinutes.remainder(60).toString().padLeft(2, '0')}:${value.inSeconds.remainder(60).toString().padLeft(2, '0')}';
}

class _VideoReelThumbnail extends StatefulWidget {
  const _VideoReelThumbnail({
    required this.videoPath,
    required this.timeMs,
    required this.width,
    required this.fallback,
    required this.onTap,
    super.key,
  });
  final String videoPath;
  final int timeMs;
  final double width;
  final File? fallback;
  final VoidCallback onTap;

  @override
  State<_VideoReelThumbnail> createState() => _VideoReelThumbnailState();
}

class _VideoReelThumbnailState extends State<_VideoReelThumbnail> {
  Future<File?>? _thumbnail;

  @override
  void initState() {
    super.initState();
    _thumbnail = createReelFrame(widget.videoPath, widget.timeMs);
  }

  @override
  void didUpdateWidget(covariant _VideoReelThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPath != widget.videoPath ||
        oldWidget.timeMs != widget.timeMs) {
      _thumbnail = createReelFrame(widget.videoPath, widget.timeMs);
    }
  }

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: widget.onTap,
    child: SizedBox(
      width: widget.width,
      child: FutureBuilder<File?>(
        future: _thumbnail,
        builder: (_, snapshot) {
          final frame = snapshot.data ?? widget.fallback;
          return frame == null
              ? const ColoredBox(color: Color(0xFF151515))
              : Image.file(frame, fit: BoxFit.cover);
        },
      ),
    ),
  );
}


enum EditorTool {
  edit,
  style,
  addText,
  fonts,
  templates,
  effects,
  overlay,
  captions,
  aspectRatio,
}

class EditorToolRail extends StatelessWidget {
  const EditorToolRail({required this.onTap, super.key});
  final ValueChanged<EditorTool> onTap;

  @override
  Widget build(BuildContext context) {
    const tools = [
      (EditorTool.style, Icons.tune_rounded, 'Customize'),
      (EditorTool.addText, Icons.edit_note_rounded, 'Edit Text'),
      (EditorTool.fonts, Icons.text_fields_rounded, 'Font'),
      (EditorTool.templates, Icons.auto_fix_high_rounded, 'Style'),
      (EditorTool.aspectRatio, Icons.crop_free_rounded, 'Aspect'),
      (EditorTool.effects, Icons.blur_on_rounded, 'Effects'),
      (EditorTool.captions, Icons.subtitles_rounded, 'Captions'),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      decoration: const BoxDecoration(color: AppColors.canvas),
      child: SizedBox(
        height: 64,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: tools.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (_, index) {
            final entry = tools[index];
            return InkWell(
              onTap: () => onTap(entry.$1),
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 76,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ModernRailIcon(icon: entry.$2),
                    const SizedBox(height: 6),
                    Text(
                      entry.$3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EditorFloatingSidebar extends StatelessWidget {
  const _EditorFloatingSidebar({required this.onTap, super.key});
  final ValueChanged<EditorTool> onTap;

  @override
  Widget build(BuildContext context) {
    const tools = [
      (EditorTool.style, Icons.tune_rounded, 'Customize'),
      (EditorTool.addText, Icons.edit_note_rounded, 'Edit Text'),
      (EditorTool.fonts, Icons.text_fields_rounded, 'Font'),
      (EditorTool.templates, Icons.auto_fix_high_rounded, 'Style'),
      (EditorTool.effects, Icons.blur_on_rounded, 'Effects'),
      (EditorTool.captions, Icons.subtitles_rounded, 'Captions'),
    ];
    return Container(
      width: 64,
      margin: const EdgeInsets.fromLTRB(16, 48, 4, 16),
      child: Card(
        color: Colors.black.withValues(alpha: 0.65),
        elevation: 8,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grab handle / Small stick
              Container(
                width: 24,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(height: 10),
              ...tools.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: InkWell(
                    onTap: () => onTap(entry.$1),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 56,
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(entry.$2, size: 20, color: Colors.white),
                          const SizedBox(height: 4),
                          Text(
                            entry.$3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showEditorToolSheet(
  BuildContext context,
  WidgetRef ref,
  EditorTool tool,
  Map<String, dynamic>? transcription,
) async {
  final labels = {
    EditorTool.edit: 'Edit',
    EditorTool.style: 'Customize',
    EditorTool.addText: 'Edit Text',
    EditorTool.fonts: 'Font',
    EditorTool.templates: 'Style',
    EditorTool.effects: 'Effects',
    EditorTool.overlay: 'Overlay',
    EditorTool.captions: 'Captions',
  };
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        final design = ref.read(captionDesignProvider);
        final editorTranscription =
            ref.read(transcriptionProvider) ??
            ref.read(projectsProvider).selected?.transcription ??
            transcription;
        void updateDesign(CaptionDesign value) {
          ref.read(captionDesignProvider.notifier).state = value;
          setSheetState(() {});
        }

        Widget content;
        if (tool == EditorTool.fonts) {
          const fonts = [
            FontPreviewChoice(CaptionFont.bungee, 'Bungee', 'BUNGEE'),
            FontPreviewChoice(CaptionFont.chivo, 'Chivo', 'Chivo'),
            FontPreviewChoice(CaptionFont.comfortaa, 'Comfortaa', 'Comfortaa'),
            FontPreviewChoice(CaptionFont.cormorant, 'Cormorant', 'Cormorant'),
            FontPreviewChoice(
              CaptionFont.fredoka,
              'Fredoka One',
              'Fredoka one',
            ),
            FontPreviewChoice(
              CaptionFont.leagueGothic,
              'League Gothic',
              'League Gothic',
            ),
            FontPreviewChoice(
              CaptionFont.lilitaOne,
              'Lilita One',
              'Lilita One',
            ),
            FontPreviewChoice(CaptionFont.lobster, 'Lobster', 'Lobster'),
            FontPreviewChoice(CaptionFont.pacifico, 'Pacifico', 'Pacifico'),
            FontPreviewChoice(
              CaptionFont.ptSansNarrow,
              'PT Sans Narrow',
              'PT Sans Narrow',
            ),
            FontPreviewChoice(
              CaptionFont.rubikWetPaint,
              'Rubik Wet Paint',
              'Rubik Wetpaint',
            ),
            FontPreviewChoice(CaptionFont.rye, 'Rye', 'Rye'),
            FontPreviewChoice(
              CaptionFont.secularOne,
              'Secular One',
              'Secular one',
            ),
            FontPreviewChoice(
              CaptionFont.staatliches,
              'Staatliches',
              'STAATLICHES',
            ),
            FontPreviewChoice(
              CaptionFont.truculenta,
              'Truculenta',
              'Truculenta',
            ),
            FontPreviewChoice(CaptionFont.tiltWarp, 'Tilt Warp', 'Tilt Warp'),
            FontPreviewChoice(
              CaptionFont.montserrat,
              'Montserrat',
              'Montserrat',
            ),
            FontPreviewChoice(CaptionFont.sriracha, 'Sriracha', 'Sriracha'),
            FontPreviewChoice(CaptionFont.anton, 'Anton', 'Anton'),
            FontPreviewChoice(
              CaptionFont.archivoBlack,
              'Archivo Black',
              'Archivo Black',
            ),
            FontPreviewChoice(CaptionFont.baloo2, 'Baloo 2', 'Baloo 2'),
            FontPreviewChoice(CaptionFont.caveat, 'Caveat', 'Caveat'),
            FontPreviewChoice(CaptionFont.dmSans, 'DM Sans', 'DM Sans'),
            FontPreviewChoice(CaptionFont.inter, 'Inter', 'Inter'),
            FontPreviewChoice(
              CaptionFont.jetBrainsMono,
              'JetBrains Mono',
              'JetBrains Mono',
            ),
            FontPreviewChoice(CaptionFont.manrope, 'Manrope', 'Manrope'),
            FontPreviewChoice(CaptionFont.oswald, 'Oswald', 'Oswald'),
            FontPreviewChoice(
              CaptionFont.permanentMarker,
              'Permanent Marker',
              'Permanent Marker',
            ),
            FontPreviewChoice(
              CaptionFont.playfair,
              'Playfair Display',
              'Playfair Display',
            ),
            FontPreviewChoice(CaptionFont.poppins, 'Poppins', 'Poppins'),
            FontPreviewChoice(CaptionFont.righteous, 'Righteous', 'Righteous'),
            FontPreviewChoice(
              CaptionFont.spaceGrotesk,
              'Space Grotesk',
              'Space Grotesk',
            ),
            FontPreviewChoice(CaptionFont.syne, 'Syne', 'Syne'),
            FontPreviewChoice(
              CaptionFont.abril,
              'Abril Fatface',
              'Abril Fatface',
            ),
            FontPreviewChoice(
              CaptionFont.rubikMono,
              'Rubik Mono One',
              'Rubik Mono One',
            ),
            FontPreviewChoice(
              CaptionFont.pixel,
              'Press Start 2P',
              'Press Start 2P',
            ),
          ];
          content = SizedBox(
            height: 282,
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 28),
              itemCount: fonts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.25,
              ),
              itemBuilder: (_, index) => FontPreviewCard(
                choice: fonts[index],
                selected: design.font == fonts[index].font,
                onTap: () =>
                    updateDesign(design.copyWith(font: fonts[index].font)),
              ),
            ),
          );
        } else if (tool == EditorTool.templates) {
          const templates = ['Warm Stage'];
          content = SizedBox(
            height: 356,
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 28),
              itemCount: templates.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: .90,
              ),
              itemBuilder: (_, index) {
                final name = templates[index];
                final selected =
                    ref.read(projectsProvider).selected?.template == name;
                return TemplateStyleCard(
                  name: name,
                  selected: selected,
                  onTap: () async {
                    updateDesign(CaptionDesign.fromTemplate(name));
                    await ref.read(projectsProvider).updateTemplate(name);
                  },
                );
              },
            ),
          );
        } else if (tool == EditorTool.effects) {
          content = SizedBox(
            height: 370,
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: CaptionEffect.values.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.16,
              ),
              itemBuilder: (_, index) {
                final effect = CaptionEffect.values[index];
                return EffectPreviewCard(
                  effect: effect,
                  selected: design.effect == effect,
                  onTap: () => updateDesign(design.copyWith(effect: effect)),
                );
              },
            ),
          );
        } else if (tool == EditorTool.captions) {
          final segments = editorTranscription?['segments'];
          final count = segments is List ? segments.length : 0;
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Show captions',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Toggle caption overlay in the preview',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: design.visible,
                      activeThumbColor: Colors.black,
                      activeTrackColor: Colors.white,
                      onChanged: (value) =>
                          updateDesign(design.copyWith(visible: value)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$count generated caption segments',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => showCustomizeSheet(sheetContext, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.secondary),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Customize subtitle style'),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Tap an individual word on the caption track to edit its text and exact timing without leaving the editor.',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              CaptionWordOverview(transcription: editorTranscription),
            ],
          );
        } else if (tool == EditorTool.edit) {
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ToolInfoRow(
                icon: Icons.content_cut_rounded,
                title: 'Trim',
                detail: 'Tap a video clip on the timeline to move the playhead before trimming.',
              ),
              const _ToolInfoRow(
                icon: Icons.speed_rounded,
                title: 'Speed',
                detail: 'Speed controls will be added with the render pass.',
              ),
              const _ToolInfoRow(
                icon: Icons.fit_screen_outlined,
                title: 'Canvas',
                detail: 'The preview keeps the original video aspect ratio.',
              ),
            ],
          );
        } else {
          content = Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.layers_outlined, size: 30),
                SizedBox(height: 12),
                Text(
                  'B-roll is coming next',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 5),
                Text(
                  'This workspace is ready for B-roll clips and overlays after the caption editor flow is finalized.',
                  style: TextStyle(color: AppColors.secondary, height: 1.4),
                ),
              ],
            ),
          );
        }

        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.sizeOf(sheetContext).height *
                  (tool == EditorTool.templates
                      ? .56
                      : tool == EditorTool.fonts
                      ? .50
                      : tool == EditorTool.effects
                      ? .68
                      : .54),
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.tertiary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  labels[tool]!,
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                content,
              ],
            ),
          ),
        );
      },
    ),
  );
}

Future<void> pickAudioForProject(BuildContext context, WidgetRef ref) async {
  try {
    final file = await FilePicker.pickFile(type: FileType.audio);
    final path = file == null ? null : file.xFile.path;
    if (path == null || path.isEmpty) return;
    await ref.read(projectsProvider).updateAudio(path);
    if (context.mounted)
      showAppMessage(
        context,
        '${file?.name ?? 'Audio'} added to the timeline.',
      );
  } on PlatformException {
    if (context.mounted)
      showAppMessage(
        context,
        'The audio picker could not open. Please try again.',
      );
  }
}

Future<void> replaceVideoForProject(BuildContext context, WidgetRef ref) async {
  try {
    final file = await FilePicker.pickFile(type: FileType.video);
    final path = file == null ? null : file.xFile.path;
    if (path == null || path.isEmpty) return;
    await ref.read(projectsProvider).replaceSelectedVideo(path);
    if (context.mounted)
      showAppMessage(context, 'Video restored for this project.');
  } on PlatformException {
    if (context.mounted)
      showAppMessage(
        context,
        'The video picker could not open. Please try again.',
      );
  }
}

class _ToolInfoRow extends StatelessWidget {
  const _ToolInfoRow({
    required this.icon,
    required this.title,
    required this.detail,
  });
  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(
                detail,
                style: const TextStyle(
                  color: AppColors.secondary,
                  height: 1.35,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Future<void> showFullscreenPreview(
  BuildContext context,
  String videoPath,
  Map<String, dynamic>? transcription,
  CaptionDesign design,
) async {
  if (!videoPathAvailable(videoPath)) {
    showAppMessage(
      context,
      'Choose the video again before opening full preview.',
    );
    return;
  }
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => _FullscreenVideoPreview(
        videoPath: videoPath,
        transcription: transcription,
        design: design,
      ),
    ),
  );
}

class _FullscreenVideoPreview extends StatefulWidget {
  const _FullscreenVideoPreview({
    required this.videoPath,
    required this.transcription,
    required this.design,
  });
  final String videoPath;
  final Map<String, dynamic>? transcription;
  final CaptionDesign design;

  @override
  State<_FullscreenVideoPreview> createState() =>
      _FullscreenVideoPreviewState();
}

class _FullscreenVideoPreviewState extends State<_FullscreenVideoPreview> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    final controller = createVideoController(widget.videoPath);
    await controller.initialize();
    controller.addListener(_refresh);
    if (!mounted) {
      controller.dispose();
      return;
    }
    setState(() => _controller = controller);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_refresh);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: controller == null
                  ? const CircularProgressIndicator(color: Colors.white)
                  : AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: GestureDetector(
                        onTap: () => controller.value.isPlaying
                            ? controller.pause()
                            : controller.play(),
                        child: Stack(
                          children: [
                            Positioned.fill(child: VideoPlayer(controller)),
                            _CaptionOverlay(
                              transcription: widget.transcription,
                              position: controller.value.position,
                              design: widget.design,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showCaptionTextEditor(
  BuildContext context,
  String videoPath,
  Map<String, dynamic>? transcription,
) async {
  if (!videoPathAvailable(videoPath)) {
    showAppMessage(context, 'Choose the video again before editing captions.');
    return;
  }
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => _CaptionTextEditorScreen(
        videoPath: videoPath,
        fallbackTranscription: transcription,
      ),
    ),
  );
}

class _CaptionTextEditorScreen extends ConsumerStatefulWidget {
  const _CaptionTextEditorScreen({
    required this.videoPath,
    required this.fallbackTranscription,
  });
  final String videoPath;
  final Map<String, dynamic>? fallbackTranscription;

  @override
  ConsumerState<_CaptionTextEditorScreen> createState() =>
      _CaptionTextEditorScreenState();
}

class _CaptionTextEditorScreenState
    extends ConsumerState<_CaptionTextEditorScreen> {
  VideoPlayerController? _controller;
  final FocusNode _paragraphFocus = FocusNode();
  final FocusNode _wordFocus = FocusNode();
  TextEditingController? _paragraphController;
  TextEditingController? _wordController;
  int? _editingRow;
  int? _editingWord;
  int? _selectedWord;
  bool _wordMode = false;

  @override
  void initState() {
    super.initState();
    _openPreview();
  }

  Future<void> _openPreview() async {
    final controller = createVideoController(widget.videoPath);
    await controller.initialize();
    controller.addListener(_refresh);
    if (!mounted) {
      controller.dispose();
      return;
    }
    setState(() => _controller = controller);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _beginParagraphEditing(int index, String text) {
    _paragraphController?.dispose();
    _paragraphController = TextEditingController(text: text);
    setState(() => _editingRow = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _paragraphFocus.requestFocus();
      _paragraphController?.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _paragraphController?.text.length ?? 0,
      );
    });
  }

  Future<void> _saveParagraphEdit(Map<String, dynamic>? transcription) async {
    final index = _editingRow;
    final value = _paragraphController?.text.trim() ?? '';
    if (index == null || value.isEmpty) return;
    await saveTranscriptSegmentText(ref, transcription, index, value);
    if (mounted) setState(() => _editingRow = null);
    _paragraphController?.dispose();
    _paragraphController = null;
  }

  void _beginWordEditing(int index, String text) {
    _wordController?.dispose();
    _wordController = TextEditingController(text: text);
    setState(() {
      _editingWord = index;
      _selectedWord = index;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _wordFocus.requestFocus();
      _wordController?.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _wordController?.text.length ?? 0,
      );
    });
  }

  Future<void> _saveWordEdit(
    Map<String, dynamic>? transcription,
    List<_TranscriptWord> words,
    List<Map> segments,
  ) async {
    final index = _editingWord;
    final value = _wordController?.text.trim() ?? '';
    if (index == null || value.isEmpty || index >= words.length) return;
    final target = words[index];
    final text = segments[target.segmentIndex]['text'] as String? ?? '';
    final tokens = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (target.wordIndex >= tokens.length) return;
    tokens[target.wordIndex] = value;
    await saveTranscriptSegmentText(
      ref,
      transcription,
      target.segmentIndex,
      tokens.join(' '),
    );
    if (mounted) setState(() => _editingWord = null);
    _wordController?.dispose();
    _wordController = null;
  }

  void _toggleWordMode() {
    _paragraphController?.dispose();
    _paragraphController = null;
    _wordController?.dispose();
    _wordController = null;
    setState(() {
      _editingRow = null;
      _editingWord = null;
      _selectedWord = null;
      _wordMode = !_wordMode;
    });
  }

  @override
  void dispose() {
    _controller?.removeListener(_refresh);
    _controller?.dispose();
    _paragraphFocus.dispose();
    _wordFocus.dispose();
    _paragraphController?.dispose();
    _wordController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final design = ref.watch(captionDesignProvider);
    final transcription =
        ref.watch(transcriptionProvider) ??
        ref.watch(projectsProvider).selected?.transcription ??
        widget.fallbackTranscription;
    final rawSegments = transcription?['segments'];
    final segments = rawSegments is List
        ? rawSegments.whereType<Map>().toList()
        : <Map>[];
    final transcriptWords = _transcriptWords(segments);
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 14, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const Spacer(),
                  const Text(
                    'EDIT TEXT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => showCustomizeSheet(context, ref),
                    child: const Text('Style'),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              height: 224,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFF454545),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF6B6B6B)),
              ),
              child: controller == null
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : GestureDetector(
                      onTap: () => controller.value.isPlaying
                          ? controller.pause()
                          : controller.play(),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Opacity(opacity: 0, child: VideoPlayer(controller)),
                          _CaptionOverlay(
                            transcription: transcription,
                            position: controller.value.position,
                            design: design,
                          ),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
              child: Row(
                children: [
                  Text(
                    '${_formatPlaybackTime(controller?.value.position ?? Duration.zero)} / ${_formatPlaybackTime(controller?.value.duration ?? Duration.zero)}',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _toggleWordMode,
                    icon: Icon(
                      _wordMode
                          ? Icons.segment_rounded
                          : Icons.short_text_rounded,
                      size: 17,
                    ),
                    label: Text(_wordMode ? 'Paragraphs' : 'Words'),
                    style: TextButton.styleFrom(
                      foregroundColor: _wordMode
                          ? const Color(0xFF9FE2B8)
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: controller == null
                        ? null
                        : () => controller.value.isPlaying
                              ? controller.pause()
                              : controller.play(),
                    icon: Icon(
                      controller?.value.isPlaying == true
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.line),
            Expanded(
              child: segments.isEmpty
                  ? const Center(
                      child: Text(
                        'No captions are ready to edit yet.',
                        style: TextStyle(color: AppColors.secondary),
                      ),
                    )
                  : _wordMode
                  ? ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                      itemCount: transcriptWords.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 3),
                      itemBuilder: (_, index) {
                        final word = transcriptWords[index];
                        final editing = _editingWord == index;
                        final isSelected = _selectedWord == index;
                        final currentSeconds =
                            (controller?.value.position.inMilliseconds ?? 0) /
                            1000;
                        final isActive =
                            currentSeconds >= word.start &&
                            currentSeconds < word.end;
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() => _selectedWord = index);
                            _controller?.seekTo(
                              Duration(
                                milliseconds: (word.start * 1000).round(),
                              ),
                            );
                          },
                          onDoubleTap: editing
                              ? null
                              : () => _beginWordEditing(index, word.text),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? design.activeColor.withValues(alpha: .20)
                                  : isSelected
                                  ? Colors.white.withValues(alpha: .07)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isActive
                                    ? design.activeColor.withValues(alpha: .75)
                                    : isSelected
                                    ? Colors.white.withValues(alpha: .25)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 62,
                                  child: Text(
                                    _formatPlaybackTime(
                                      Duration(
                                        milliseconds: (word.start * 1000)
                                            .round(),
                                      ),
                                    ),
                                    style: const TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: editing
                                      ? TextField(
                                          controller: _wordController,
                                          focusNode: _wordFocus,
                                          maxLines: 1,
                                          onSubmitted: (_) => _saveWordEdit(
                                            transcription,
                                            transcriptWords,
                                            segments,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none,
                                          ),
                                        )
                                      : Text(
                                          word.text,
                                          style: TextStyle(
                                            color: isActive
                                                ? design.activeColor
                                                : const Color(0xFFE3E3E3),
                                            fontSize: 17,
                                            fontWeight: isActive
                                                ? FontWeight.w800
                                                : FontWeight.w500,
                                          ),
                                        ),
                                ),
                                if (editing)
                                  IconButton(
                                    onPressed: () => _saveWordEdit(
                                      transcription,
                                      transcriptWords,
                                      segments,
                                    ),
                                    icon: const Icon(Icons.check_rounded),
                                    color: Colors.white,
                                    splashRadius: 18,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                      itemCount: segments.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 2),
                      itemBuilder: (_, index) {
                        final segment = segments[index];
                        final start =
                            (segment['start'] as num?)?.toDouble() ?? 0;
                        final text = segment['text'] as String? ?? '';
                        final editing = _editingRow == index;
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _controller?.seekTo(
                            Duration(milliseconds: (start * 1000).round()),
                          ),
                          onDoubleTap: editing
                              ? null
                              : () {
                                  _controller?.seekTo(
                                    Duration(
                                      milliseconds: (start * 1000).round(),
                                    ),
                                  );
                                  _beginParagraphEditing(index, text);
                                },
                          child: Container(
                            color: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 13,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 62,
                                  child: Text(
                                    _formatPlaybackTime(
                                      Duration(
                                        milliseconds: (start * 1000).round(),
                                      ),
                                    ),
                                    style: const TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: editing
                                      ? TextField(
                                          controller: _paragraphController,
                                          focusNode: _paragraphFocus,
                                          maxLines: null,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          onSubmitted: (_) =>
                                              _saveParagraphEdit(transcription),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            height: 1.3,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none,
                                          ),
                                        )
                                      : Text(
                                          text,
                                          style: const TextStyle(
                                            color: Color(0xFFE3E3E3),
                                            fontSize: 18,
                                            height: 1.3,
                                          ),
                                        ),
                                ),
                                if (editing)
                                  IconButton(
                                    onPressed: () =>
                                        _saveParagraphEdit(transcription),
                                    icon: const Icon(Icons.check_rounded),
                                    color: Colors.white,
                                    splashRadius: 18,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TranscriptWord {
  const _TranscriptWord({
    required this.segmentIndex,
    required this.wordIndex,
    required this.start,
    required this.end,
    required this.text,
  });
  final int segmentIndex;
  final int wordIndex;
  final double start;
  final double end;
  final String text;
}

List<_TranscriptWord> _transcriptWords(List<Map> segments) {
  final words = <_TranscriptWord>[];
  for (var segmentIndex = 0; segmentIndex < segments.length; segmentIndex++) {
    final segment = segments[segmentIndex];
    final start = (segment['start'] as num?)?.toDouble() ?? 0;
    final end = (segment['end'] as num?)?.toDouble() ?? start + 1;
    final tokens = (segment['text'] as String? ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (tokens.isEmpty) continue;
    final slot = (end - start) / tokens.length;
    for (var wordIndex = 0; wordIndex < tokens.length; wordIndex++) {
      words.add(
        _TranscriptWord(
          segmentIndex: segmentIndex,
          wordIndex: wordIndex,
          start: start + (slot * wordIndex),
          end: start + (slot * (wordIndex + 1)),
          text: tokens[wordIndex],
        ),
      );
    }
  }
  return words;
}

String _formatPlaybackTime(Duration value) =>
    '${value.inMinutes.remainder(60).toString().padLeft(2, '0')}:${value.inSeconds.remainder(60).toString().padLeft(2, '0')}';

class VideoPreviewPlayer extends StatefulWidget {
  const VideoPreviewPlayer({
    required this.videoPath,
    required this.transcription,
    required this.design,
    required this.playback,
    required this.timelineSeek,
    required this.playbackCommand,
    required this.playbackSpeed,
    required this.previewAspect,
    required this.onReplaceVideo,
    super.key,
  });
  final String videoPath;
  final Map<String, dynamic>? transcription;
  final CaptionDesign design;
  final ValueNotifier<PlaybackInfo> playback;
  final ValueNotifier<Duration?> timelineSeek;
  final ValueNotifier<bool?> playbackCommand;
  final ValueNotifier<double> playbackSpeed;
  final ValueNotifier<PreviewAspect> previewAspect;
  final VoidCallback onReplaceVideo;

  @override
  State<VideoPreviewPlayer> createState() => _VideoPreviewPlayerState();
}

class _VideoOverlayIconButton extends StatelessWidget {
  const _VideoOverlayIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.black.withValues(alpha: .48),
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: .18)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    ),
  );
}

class _VideoPreviewPlayerState extends State<VideoPreviewPlayer> {
  VideoPlayerController? _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.timelineSeek.addListener(_seekFromTimeline);
    widget.playbackCommand.addListener(_applyPlaybackCommand);
    widget.playbackSpeed.addListener(_applyPlaybackSpeed);
    widget.previewAspect.addListener(_refreshForAspectChange);
    _initialize();
  }

  @override
  void didUpdateWidget(covariant VideoPreviewPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPath != widget.videoPath) {
      _controller?.removeListener(_listen);
      _controller?.dispose();
      _controller = null;
      _error = null;
      _initialize();
    }
  }

  Future<void> _initialize() async {
    if (!videoPathAvailable(widget.videoPath)) {
      setState(
        () => _error = 'This video is no longer available on your device.',
      );
      return;
    }
    try {
      final controller = createVideoController(widget.videoPath);
      await controller.initialize();
      await controller.setPlaybackSpeed(widget.playbackSpeed.value);
      controller.addListener(_listen);
      if (mounted) setState(() => _controller = controller);
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to open this video.');
    }
  }

  void _listen() {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      widget.playback.value = PlaybackInfo(
        position: controller.value.position,
        duration: controller.value.duration,
        isPlaying: controller.value.isPlaying,
      );
    }
    if (mounted) setState(() {});
  }

  Future<void> _seekFromTimeline() async {
    final position = widget.timelineSeek.value;
    final controller = _controller;
    if (position == null ||
        controller == null ||
        !controller.value.isInitialized) {
      return;
    }
    await controller.seekTo(position);
    widget.timelineSeek.value = null;
  }

  void _applyPlaybackCommand() {
    final command = widget.playbackCommand.value;
    final controller = _controller;
    if (command == null ||
        controller == null ||
        !controller.value.isInitialized)
      return;
    command ? controller.play() : controller.pause();
    widget.playbackCommand.value = null;
  }

  Future<void> _applyPlaybackSpeed() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    await controller.setPlaybackSpeed(widget.playbackSpeed.value);
  }

  void _refreshForAspectChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.timelineSeek.removeListener(_seekFromTimeline);
    widget.playbackCommand.removeListener(_applyPlaybackCommand);
    widget.playbackSpeed.removeListener(_applyPlaybackSpeed);
    widget.previewAspect.removeListener(_refreshForAspectChange);
    _controller?.removeListener(_listen);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.line),
          ),
          child: Center(
            child: _error == null
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                : Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.secondary),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: widget.onReplaceVideo,
                          icon: const Icon(Icons.video_library_outlined),
                          label: const Text('Choose video again'),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      );
    }
    final value = controller.value;
    final duration = value.duration;
    final position = value.position > duration ? duration : value.position;
    final videoSize = value.size;
    final selected = widget.previewAspect.value;
    final selectedRatio = selected.ratio;
    final defaultRatio = value.aspectRatio == 0 ? 9 / 16 : value.aspectRatio;
    final radius = selected == PreviewAspect.full ? 6.0 : 22.0;
    final playOverlay = Center(
      child: AnimatedOpacity(
        opacity: value.isPlaying ? 0 : 1,
        duration: const Duration(milliseconds: 150),
        child: Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: _togglePlay,
            customBorder: const CircleBorder(),
            child: const SizedBox(
              width: 64,
              height: 64,
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.black,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
    Widget frameCanvas({required bool cover}) => Stack(
      fit: StackFit.expand,
      children: [
        if (cover)
          FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: videoSize.width,
              height: videoSize.height,
              child: VideoPlayer(controller),
            ),
          )
        else
          VideoPlayer(controller),
        _CaptionOverlay(
          transcription: widget.transcription,
          position: position,
          design: widget.design,
        ),
        playOverlay,
      ],
    );
    if (selected == PreviewAspect.full) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox.expand(child: frameCanvas(cover: true)),
      );
    }
    return Center(
      child: AspectRatio(
        aspectRatio: selectedRatio ?? defaultRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: selected == PreviewAspect.original
              ? frameCanvas(cover: false)
              : SizedBox.expand(child: frameCanvas(cover: true)),
        ),
      ),
    );
  }

  void _togglePlay() =>
      _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
}

class _CaptionOverlay extends StatelessWidget {
  const _CaptionOverlay({
    required this.transcription,
    required this.position,
    required this.design,
  });
  final Map<String, dynamic>? transcription;
  final Duration position;
  final CaptionDesign design;

  @override
  Widget build(BuildContext context) {
    if (!design.visible) return const SizedBox.shrink();
    final now = position.inMilliseconds / 1000;
    final words = resolveCaptionWords(transcription);
    final groups = captionGroups(words, design.maxWordsPerLine);
    final group = groups.firstWhere(
      (candidate) =>
          now >= candidate.first.start - .1 && now <= candidate.last.end + .28,
      orElse: () => <TimedCaptionWord>[],
    );
    if (group.isEmpty) return const SizedBox.shrink();
    final activeWordIndex = group.lastIndexWhere((word) => now >= word.start);
    final selectedWordIndex = activeWordIndex < 0 ? 0 : activeWordIndex;
    final groupProgress =
        ((now - group.first.start) /
                (group.last.end - group.first.start).clamp(.1, double.infinity))
            .clamp(0.0, 1.0);
    final chunkProgress =
        ((now - group.first.start) /
                (group.first.end - group.first.start).clamp(
                  .1,
                  double.infinity,
                ))
            .clamp(0.0, 1.0);
    final opacity = design.effect == CaptionEffect.fade
        ? (chunkProgress * 5).clamp(0.0, 1.0)
        : 1.0;
    Widget wordAt(int index, {double sizeMultiplier = 1}) {
      final isActive = index == selectedWordIndex;
      final word = CaptionWord(
        text: design.uppercase
            ? group[index].text.toUpperCase()
            : group[index].text,
        style: captionTextStyle(
          design,
          color: design.wordChip
              ? (isActive ? Colors.black : Colors.white)
              : design.effect == CaptionEffect.karaoke &&
                    index <= selectedWordIndex
              ? design.activeColor
              : isActive
              ? design.activeColor
              : design.color,
          fontSize: design.size * sizeMultiplier,
        ),
        isActive: isActive,
        effect: design.effect,
        wordProgress:
            ((now - group[index].start) /
                    (group[index].end - group[index].start).clamp(
                      .1,
                      double.infinity,
                    ))
                .clamp(0.0, 1.0),
        textSize: design.size * sizeMultiplier,
        doubleLayer: design.doubleLayer,
        hardShadow: design.hardShadow,
      );
      return design.wordChip
          ? Container(
              padding: EdgeInsets.symmetric(
                horizontal: design.size * .24,
                vertical: design.size * .11,
              ),
              decoration: BoxDecoration(
                color: isActive ? design.activeColor : design.chipColor,
                borderRadius: BorderRadius.circular(design.size * .18),
              ),
              child: word,
            )
          : word;
    }

    final wordsLayout = switch (design.layout) {
      CaptionLayout.inline => Wrap(
        key: ValueKey('${group.first.start}-${group.last.end}'),
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: design.size * .22,
        runSpacing: 4,
        children: [
          for (var index = 0; index < group.length; index++)
            if (index <= selectedWordIndex) wordAt(index),
          if (design.effect == CaptionEffect.typewriter)
            Container(
              width: 2,
              height: design.size * 1.05,
              color: design.activeColor,
            ),
        ],
      ),
      CaptionLayout.ladder => Column(
        key: ValueKey('${group.first.start}-${group.last.end}'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < group.length; index++)
            if (index <= selectedWordIndex)
              Transform.translate(
                offset: Offset(index * design.size * .22, 0),
                child: wordAt(index),
              ),
        ],
      ),
      CaptionLayout.hierarchy => Column(
        key: ValueKey('${group.first.start}-${group.last.end}'),
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedWordIndex >= 0) wordAt(0, sizeMultiplier: 1.18),
          if (selectedWordIndex > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: design.size * .16,
                children: [
                  for (var index = 1; index <= selectedWordIndex; index++)
                    wordAt(index, sizeMultiplier: .86),
                ],
              ),
            ),
        ],
      ),
    };
    final caption = Transform.translate(
      offset: design.effect == CaptionEffect.slideUp
          ? Offset(0, design.size * (1 - groupProgress) * .75)
          : Offset.zero,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: .96, end: 1).animate(animation),
            child: child,
          ),
        ),
        child: wordsLayout,
      ),
    );
    final framedCaption =
        design.backgroundColor == null && design.borderColor == null
        ? caption
        : Container(
            padding: EdgeInsets.symmetric(
              horizontal: design.boxHorizontalPadding,
              vertical: design.boxVerticalPadding,
            ),
            decoration: BoxDecoration(
              color: design.backgroundColor,
              borderRadius: BorderRadius.circular(design.boxRadius),
              border: design.borderColor == null
                  ? null
                  : Border.all(color: design.borderColor!),
            ),
            child: caption,
          );
    final top = design.position == CaptionPosition.top
        ? 34.0
        : design.position == CaptionPosition.center
        ? null
        : null;
    final bottom = design.position == CaptionPosition.bottom
        ? 62.0
        : design.position == CaptionPosition.center
        ? null
        : null;
    return Positioned(
      left: 24,
      right: 24,
      top: top,
      bottom: bottom,
      child: Align(
        alignment: design.position == CaptionPosition.center
            ? Alignment.center
            : design.position == CaptionPosition.top
            ? Alignment.topCenter
            : Alignment.bottomCenter,
        child: Opacity(opacity: opacity, child: framedCaption),
      ),
    );
  }
}





class _ModernRailIcon extends StatelessWidget {
  const _ModernRailIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) =>
      Icon(icon, size: 24, color: Colors.white);
}

class FontPreviewChoice {
  const FontPreviewChoice(this.font, this.label, this.preview);
  final CaptionFont font;
  final String label;
  final String preview;
}

class FontPreviewCard extends StatelessWidget {
  const FontPreviewCard({
    required this.choice,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final FontPreviewChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sampleDesign = CaptionDesign(
      font: choice.font,
      color: const Color(0xFFE7E7EB),
      weight: FontWeight.w800,
      size: 22,
    );
    final compactFont =
        choice.font == CaptionFont.leagueGothic ||
        choice.font == CaptionFont.ptSansNarrow;
    final displayFont =
        choice.font == CaptionFont.rubikWetPaint ||
            choice.font == CaptionFont.sriracha ||
            choice.font == CaptionFont.pacifico
        ? 15.0
        : compactFont
        ? 20.0
        : 17.0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1D22),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? Colors.white : const Color(0xFF24242B),
            width: selected ? 2.3 : 1,
          ),
          boxShadow: selected
              ? const [BoxShadow(color: Color(0x33FFFFFF), blurRadius: 10)]
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  choice.label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: captionTextStyle(sampleDesign, fontSize: displayFont),
                ),
              ),
            ),
            if (selected)
              const Positioned(
                right: 1,
                top: 1,
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 15,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class EffectPreviewCard extends StatefulWidget {
  const EffectPreviewCard({
    required this.effect,
    required this.selected,
    required this.onTap,
    super.key,
  });
  final CaptionEffect effect;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<EffectPreviewCard> createState() => _EffectPreviewCardState();
}

class _EffectPreviewCardState extends State<EffectPreviewCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _motion,
      builder: (_, _) {
        final progress = Curves.easeInOut.transform(_motion.value);
        final wave = math.sin(_motion.value * math.pi * 2);
        final effect = widget.effect;
        final isTypewriter = effect == CaptionEffect.typewriter;
        final rawSample = effect.sample;
        final visibleCount = (rawSample.length * progress).round().clamp(
          1,
          rawSample.length,
        );
        final sample = isTypewriter
            ? rawSample.substring(0, visibleCount)
            : rawSample;
        final opacity = switch (effect) {
          CaptionEffect.fade => .45 + progress * .55,
          CaptionEffect.slideUp => .35 + progress * .65,
          CaptionEffect.stagger => .55 + progress * .45,
          _ => 1.0,
        };
        final scale = switch (effect) {
          CaptionEffect.pop => .94 + progress * .08,
          CaptionEffect.pulse => 1 + wave.abs() * .07,
          CaptionEffect.bounce => 1 + wave.abs() * .025,
          _ => 1.0,
        };
        final offset = switch (effect) {
          CaptionEffect.bounce => Offset(0, -wave.abs() * 5),
          CaptionEffect.slideUp => Offset(0, (1 - progress) * 8),
          CaptionEffect.stagger => Offset((1 - progress) * 5, 0),
          CaptionEffect.drift => Offset(
            wave * 4,
            math.cos(_motion.value * math.pi * 2) * 2,
          ),
          _ => Offset.zero,
        };
        return InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.selected
                  ? Colors.white.withValues(alpha: .12)
                  : AppColors.elevated,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: widget.selected ? Colors.white : AppColors.line,
                width: widget.selected ? 1.8 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        effect.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: effect.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (widget.selected)
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 17,
                        color: Colors.white,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: effect.accent.withValues(alpha: .28),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (effect == CaptionEffect.karaoke)
                          FractionallySizedBox(
                            widthFactor: .45 + progress * .45,
                            child: Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: effect.accent.withValues(alpha: .42),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        Transform.translate(
                          offset: offset,
                          child: Transform.scale(
                            scale: scale,
                            child: Opacity(
                              opacity: opacity,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  sample,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: effect.accent,
                                    fontSize: isTypewriter ? 11 : 14,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: isTypewriter ? .2 : .1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (isTypewriter)
                          Positioned(
                            right: 14,
                            child: Opacity(
                              opacity: .55 + wave.abs() * .45,
                              child: Text(
                                '|',
                                style: TextStyle(
                                  color: effect.accent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  effect.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 10,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TemplateStyleCard extends StatefulWidget {
  const TemplateStyleCard({
    required this.name,
    required this.selected,
    required this.onTap,
    super.key,
  });
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<TemplateStyleCard> createState() => _TemplateStyleCardState();
}

class _TemplateStyleCardState extends State<TemplateStyleCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2400 + widget.name.length * 14),
    )..repeat();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final design = CaptionDesign.fromTemplate(widget.name);
    final sample = switch (widget.name) {
      'Podcast Minimal' => ['make it', 'feel cinematic'],
      'Emphasis Outline' => ['WATCH', 'THIS PART'],
      'Clean Box' => ['Clear words', 'every time'],
      'Bubble' => ['keep it', 'friendly'],
      'Hormozi Bold' => ['MAKE', 'IT HIT'],
      'MrBeast Impact' => ['STOP', 'SCROLLING'],
      'Karaoke Bar' => ['FOLLOW', 'THE FLOW'],
      'Gold Shadow' => ['YOUR', 'BIG MOMENT'],
      'Neon Highlight' => ['LIGHT', 'UP'],
      'Double Pop' => ['DOUBLE', 'ENERGY'],
      'Left Ladder' => ['one', 'two', 'three', 'four'],
      'Stacked Punch' => ['WORD', 'BY', 'WORD'],
      'Soft Talk' => ['say it', 'naturally'],
      'Coral Punch' => ['SPEAK', 'LOUD'],
      'Electric Wave' => ['RIDE', 'THE WAVE'],
      'Mono Signal' => ['tell', 'your story'],
      'Halo Words' => ['glow', 'different'],
      'Marker Pop' => ['MAKE', 'A MARK'],
      'Nightline' => ['after', 'dark'],
      'Retro Offset' => ['OLD', 'SCHOOL'],
      'Quiet Outline' => ['keep', 'watching'],
      'Cloud Float' => ['float', 'on'],
      'Fire Starter' => ['START', 'FIRE'],
      'Cinema Serif' => ['cinematic', 'stories'],
      'Script Bloom' => ['beautiful', 'moments'],
      'Poster Ink' => ['MAKE', 'A MOVE'],
      'Block Parade' => ['BIG', 'ENERGY'],
      'Prism Grotesk' => ['SHIFT', 'THE LIGHT'],
      'Arcade Pulse' => ['LEVEL', 'UP'],
      'Luxe Title' => ['the', 'moment'],
      'Velvet Script' => ['say it', 'softly'],
      'Classic Cut' => ['CUT', 'TO IT'],
      'Reel Candy' => ['SWEET', 'SPOT'],
      'Blackout Bold' => ['NO', 'FILTER'],
      'Pixel Snap' => ['NEXT', 'FRAME'],
      'Sunbeam Serif' => ['golden', 'hour'],
      'Doodle Yellow' => ['YOUR', 'TURN'],
      'Bubble Chrome' => ['LOOK', 'CLOSER'],
      'Clean Digital' => ['signal', 'clear'],
      'Film Noir' => ['after', 'hours'],
      'Sunset Script' => ['dream', 'bigger'],
      'Viva Poster' => ['live', 'loud'],
      'Soda Pop' => ['fresh', 'take'],
      'Urban Mono' => ['STAY', 'READY'],
      'Chrome Marker' => ['MAKE', 'NOISE'],
      'Neon Serif' => ['glow', 'up'],
      'Storybook Script' => ['once', 'again'],
      'Punchline Sans' => ['THE', 'HOOK'],
      'Solar Build' => ['BUILD', 'THE', 'MOMENT'],
      'Hard Echo' => ['SAY', 'IT', 'LOUD'],
      'Midnight Chip' => ['keep', 'the', 'flow'],
      'Focus Pixel' => ['LEVEL', 'UP'],
      'Velvet Three' => ['your', 'story', 'matters'],
      'Ember Karaoke' => ['THIS', 'IS', 'THE BEAT'],
      'Prism Stack' => ['make', 'it', 'move'],
      'Noir Plate' => ['after', 'the', 'cut'],
      'Signal Tag' => ['clear', 'the', 'noise'],
      'Mint Outline' => ['KEEP', 'WATCHING'],
      'Horizon Slide' => ['GO', 'BEYOND'],
      'Paper Stamp' => ['START', 'NOW'],
      'Warm Stage' => ['THE', 'BIG MOMENT'],
      'Blink Pop' => ['MAKE', 'IT POP'],
      _ => ['TALK', 'NATURALLY'],
    };
    final angle = switch (widget.name) {
      'Karaoke Bar' => -.035,
      'Coral Punch' => -.06,
      'Neon Highlight' => .035,
      'Mono Signal' => -.025,
      'Fire Starter' => .055,
      _ => 0.0,
    };
    return AnimatedBuilder(
      animation: _motion,
      builder: (context, _) {
        final progress = Curves.easeInOut.transform(_motion.value);
        final sequenceProgress = (progress / .78).clamp(0.0, 1.0).toDouble();
        final activeIndex = ((sequenceProgress * sample.length).floor()).clamp(
          0,
          sample.length - 1,
        );
        final isBounce =
            design.effect == CaptionEffect.bounce ||
            design.effect == CaptionEffect.pop ||
            design.effect == CaptionEffect.pulse;
        final scale = isBounce ? .92 + (progress * .10) : 1.0;
        final rise =
            design.effect == CaptionEffect.slideUp ||
                design.effect == CaptionEffect.stagger
            ? (1 - progress) * 10
            : design.effect == CaptionEffect.drift
            ? (progress - .5) * 8
            : 0.0;
        return InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: widget.selected
                  ? const Color(0xFF34313D)
                  : AppColors.elevated,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: widget.selected ? Colors.white : AppColors.line,
                width: widget.selected ? 1.7 : 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Transform.translate(
                    offset: Offset(0, -rise),
                    child: Transform.scale(
                      scale: scale,
                      child: Transform.rotate(
                        angle:
                            angle +
                            (design.effect == CaptionEffect.drift
                                ? (progress - .5) * .035
                                : 0),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: design.boxHorizontalPadding / 1.7,
                            vertical: design.boxVerticalPadding / 1.6,
                          ),
                          decoration: BoxDecoration(
                            color: design.backgroundColor,
                            borderRadius: BorderRadius.circular(
                              design.boxRadius,
                            ),
                            border: design.borderColor == null
                                ? null
                                : Border.all(
                                    color: design.borderColor!,
                                    width: 1.2,
                                  ),
                            boxShadow: design.glow
                                ? [
                                    BoxShadow(
                                      color: design.activeColor.withValues(
                                        alpha: .52,
                                      ),
                                      blurRadius: 12 + progress * 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                                design.layout == CaptionLayout.ladder
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                            children: [
                              for (
                                var index = 0;
                                index < sample.length;
                                index++
                              )
                                Builder(
                                  builder: (_) {
                                    final wordProgress =
                                        (sequenceProgress * sample.length -
                                                index)
                                            .clamp(0.0, 1.0)
                                            .toDouble();
                                    final wordIsActive = index == activeIndex;
                                    final wordScale = isBounce
                                        ? .82 +
                                              (.18 *
                                                  Curves.easeOutBack.transform(
                                                    wordProgress,
                                                  ))
                                        : 1.0;
                                    final previewText = Text(
                                      design.uppercase
                                          ? sample[index].toUpperCase()
                                          : sample[index],
                                      textAlign: TextAlign.center,
                                      style: captionTextStyle(
                                        design,
                                        color: design.wordChip
                                            ? (wordIsActive
                                                  ? Colors.black
                                                  : Colors.white)
                                            : wordIsActive
                                            ? design.activeColor
                                            : design.color,
                                        fontSize:
                                            design.font == CaptionFont.pixel ||
                                                design.font ==
                                                    CaptionFont.rubikMono
                                            ? 11
                                            : design.font ==
                                                      CaptionFont.caveat ||
                                                  design.font ==
                                                      CaptionFont.lobster
                                            ? 21
                                            : 17,
                                      ),
                                    );
                                    final framedPreview = design.wordChip
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: wordIsActive
                                                  ? design.activeColor
                                                  : design.chipColor,
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: previewText,
                                          )
                                        : previewText;
                                    return Transform.translate(
                                      offset:
                                          design.layout == CaptionLayout.ladder
                                          ? Offset(
                                              index * 6.0,
                                              (1 - wordProgress) * 7,
                                            )
                                          : Offset(0, (1 - wordProgress) * 8),
                                      child: Transform.scale(
                                        scale: wordScale,
                                        child: Opacity(
                                          opacity: wordProgress,
                                          child: design.hardShadow
                                              ? Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Positioned(
                                                      left: 2,
                                                      top: 2,
                                                      child: Text(
                                                        design.uppercase
                                                            ? sample[index]
                                                                  .toUpperCase()
                                                            : sample[index],
                                                        style: captionTextStyle(
                                                          design,
                                                          color: Colors.black,
                                                          fontSize: 17,
                                                        ),
                                                      ),
                                                    ),
                                                    framedPreview,
                                                  ],
                                                )
                                              : framedPreview,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.selected)
                  const Positioned(
                    top: 9,
                    right: 9,
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                Positioned(
                  left: 10,
                  bottom: 9,
                  child: Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CaptionWordOverview extends StatelessWidget {
  const CaptionWordOverview({required this.transcription, super.key});
  final Map<String, dynamic>? transcription;

  @override
  Widget build(BuildContext context) {
    final words = resolveCaptionWords(transcription);
    if (words.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.line),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: words
            .take(28)
            .map(
              (word) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                color: AppColors.elevated,
                child: Text(
                  '${_formatPreciseTime(word.start)}  ${word.text}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

String _formatPreciseTime(double seconds) {
  final duration = Duration(milliseconds: (seconds * 1000).round());
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final hundredths = (duration.inMilliseconds.remainder(1000) ~/ 10)
      .toString()
      .padLeft(2, '0');
  return '$minutes:$secs.$hundredths';
}

Future<void> saveTranscriptSegmentText(
  WidgetRef ref,
  Map<String, dynamic>? fallback,
  int segmentIndex,
  String text,
) async {
  final current =
      ref.read(transcriptionProvider) ??
      ref.read(projectsProvider).selected?.transcription ??
      fallback;
  final rawSegments = current?['segments'];
  if (current == null || rawSegments is! List || text.trim().isEmpty) return;
  if (segmentIndex < 0 || segmentIndex >= rawSegments.length) return;
  final updatedSegments = List<dynamic>.from(rawSegments);
  final target = updatedSegments[segmentIndex];
  if (target is! Map) return;
  final targetSegment = Map<String, dynamic>.from(target);
  final start = (targetSegment['start'] as num?)?.toDouble() ?? 0;
  final end = (targetSegment['end'] as num?)?.toDouble() ?? start + .1;
  final replacementTokens = text
      .trim()
      .split(RegExp(r'\s+'))
      .where((token) => token.isNotEmpty)
      .toList();
  final oldWords = resolveCaptionWords(current);
  var wordOffset = 0;
  for (var index = 0; index < segmentIndex; index++) {
    final segment = rawSegments[index];
    if (segment is Map) {
      wordOffset += (segment['text'] as String? ?? '')
          .trim()
          .split(RegExp(r'\s+'))
          .where((token) => token.isNotEmpty)
          .length;
    }
  }
  final oldTokenCount = (targetSegment['text'] as String? ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((token) => token.isNotEmpty)
      .length;
  final span =
      ((end - start).clamp(.1, double.infinity)) / replacementTokens.length;
  final replacementWords = replacementTokens.indexed
      .map(
        (entry) => TimedCaptionWord(
          text: entry.$2,
          start: start + span * entry.$1,
          end: entry.$1 == replacementTokens.length - 1
              ? end
              : start + span * (entry.$1 + 1),
        ),
      )
      .toList();
  final updatedWords = [
    ...oldWords.take(wordOffset),
    ...replacementWords,
    ...oldWords.skip(wordOffset + oldTokenCount),
  ];
  updatedSegments[segmentIndex] = {...targetSegment, 'text': text.trim()};
  final updated = Map<String, dynamic>.from(current)
    ..['segments'] = updatedSegments
    ..['words'] = updatedWords
        .map(
          (word) => {'text': word.text, 'start': word.start, 'end': word.end},
        )
        .toList();
  ref.read(transcriptionProvider.notifier).state = updated;
  await ref.read(projectsProvider).saveTranscript(updated);
}

Future<void> showCustomizeSheet(BuildContext context, WidgetRef ref) async {
  var customColorPage = false;
  Color? colorBeforeCustomPage;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        final design = ref.read(captionDesignProvider);
        final recentColors = ref.read(captionRecentColorsProvider);
        void update(CaptionDesign value) {
          ref.read(captionDesignProvider.notifier).state = value;
          setSheetState(() {});
        }

        void applyCaptionColor(Color color, {bool addToRecent = false}) {
          update(design.copyWith(color: color, activeColor: color));
          if (!addToRecent) return;
          final updatedRecent = [
            color,
            ...recentColors.where(
              (item) => item.toARGB32() != color.toARGB32(),
            ),
          ].take(4).toList();
          ref.read(captionRecentColorsProvider.notifier).state = updatedRecent;
        }

        if (customColorPage) {
          return Theme(
            data: Theme.of(sheetContext).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: SafeArea(
              top: false,
              child: _InSheetCustomColorPage(
                initialColor: design.color,
                onLiveChange: (color) =>
                    update(design.copyWith(color: color, activeColor: color)),
                onBack: () {
                  final restore = colorBeforeCustomPage ?? design.color;
                  update(design.copyWith(color: restore, activeColor: restore));
                  colorBeforeCustomPage = null;
                  setSheetState(() => customColorPage = false);
                },
                onApply: (color) {
                  applyCaptionColor(color, addToRecent: true);
                  colorBeforeCustomPage = null;
                  setSheetState(() => customColorPage = false);
                },
              ),
            ),
          );
        }

        return Theme(
          data: Theme.of(sheetContext).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            colorScheme: Theme.of(sheetContext).colorScheme
                .copyWith(primary: Colors.white, secondary: Colors.white),
          ),
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.tertiary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Customize captions',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Size',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Text(
                        '${design.size.round()} px',
                        style: const TextStyle(color: AppColors.secondary),
                      ),
                    ],
                  ),
                  Slider(
                    value: design.size,
                    min: 18,
                    max: 42,
                    divisions: 12,
                    activeColor: Colors.white,
                    inactiveColor: AppColors.line,
                    onChanged: (value) => update(design.copyWith(size: value)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Position',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 8,
                    children: CaptionPosition.values
                        .map(
                          (position) => ChoiceChip(
                            label: Text(
                              position.name[0].toUpperCase() +
                                  position.name.substring(1),
                            ),
                            selected: design.position == position,
                            onSelected: (_) =>
                                update(design.copyWith(position: position)),
                            selectedColor: Colors.white,
                            backgroundColor: AppColors.elevated,
                            labelStyle: TextStyle(
                              color: design.position == position
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            side: BorderSide(
                              color: design.position == position
                                  ? Colors.white
                                  : AppColors.line,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Text color',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      ...recentColors.map(
                        (color) => InkWell(
                          onTap: () => applyCaptionColor(color),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: design.color == color
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          colorBeforeCustomPage = design.color;
                          setSheetState(() => customColorPage = true);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const SweepGradient(
                              colors: [
                                Color(0xFFFF4D4D),
                                Color(0xFFFFD34E),
                                Color(0xFF72E06A),
                                Color(0xFF44C7FF),
                                Color(0xFF7858FF),
                                Color(0xFFFF5EBE),
                                Color(0xFFFF4D4D),
                              ],
                            ),
                            border: Border.all(color: Colors.white54),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 21,
                            height: 21,
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Weight',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 8,
                    children:
                        [FontWeight.w500, FontWeight.w700, FontWeight.w900]
                            .map(
                              (weight) => ChoiceChip(
                                label: Text(
                                  weight == FontWeight.w500
                                      ? 'Regular'
                                      : weight == FontWeight.w700
                                      ? 'Bold'
                                      : 'Extra bold',
                                ),
                                selected: design.weight == weight,
                                onSelected: (_) =>
                                    update(design.copyWith(weight: weight)),
                                selectedColor: Colors.white,
                                backgroundColor: AppColors.elevated,
                                labelStyle: TextStyle(
                                  color: design.weight == weight
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                side: BorderSide(
                                  color: design.weight == weight
                                      ? Colors.white
                                      : AppColors.line,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _InSheetCustomColorPage extends StatefulWidget {
  const _InSheetCustomColorPage({
    required this.initialColor,
    required this.onLiveChange,
    required this.onBack,
    required this.onApply,
  });
  final Color initialColor;
  final ValueChanged<Color> onLiveChange;
  final VoidCallback onBack;
  final ValueChanged<Color> onApply;

  @override
  State<_InSheetCustomColorPage> createState() =>
      _InSheetCustomColorPageState();
}

class _InSheetCustomColorPageState extends State<_InSheetCustomColorPage> {
  late final TextEditingController _hexController;
  late double _hue;
  late double _saturation;
  late double _value;

  Color get _color => HSVColor.fromAHSV(1, _hue, _saturation, _value).toColor();

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initialColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
    _hexController = TextEditingController(text: _captionColorHex(_color));
  }

  void _syncHex() => _hexController.text = _captionColorHex(_color);

  void _updateSquare(Offset position, Size size) {
    setState(() {
      _saturation = (position.dx / size.width).clamp(0.0, 1.0);
      _value = (1 - position.dy / size.height).clamp(0.0, 1.0);
      _syncHex();
    });
    widget.onLiveChange(_color);
  }

  void _updateHue(Offset position, Size size) {
    setState(() {
      _hue = (position.dx / size.width).clamp(0.0, 1.0) * 360;
      _syncHex();
    });
    widget.onLiveChange(_color);
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(
      24,
      10,
      24,
      20 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.center,
          child: Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.tertiary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
            ),
            const SizedBox(width: 4),
            const Text(
              'Custom color',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white38),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, 190);
            return GestureDetector(
              onPanDown: (details) =>
                  _updateSquare(details.localPosition, size),
              onPanUpdate: (details) =>
                  _updateSquare(details.localPosition, size),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: size,
                        painter: _SaturationValuePainter(hue: _hue),
                      ),
                      Positioned(
                        left: ((_saturation * size.width) - 9).clamp(
                          0.0,
                          size.width - 18,
                        ),
                        top: (((1 - _value) * size.height) - 9).clamp(
                          0.0,
                          size.height - 18,
                        ),
                        child: const IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                              border: Border.fromBorderSide(
                                BorderSide(color: Colors.white, width: 2),
                              ),
                            ),
                            child: SizedBox(width: 18, height: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, 20);
            return GestureDetector(
              onPanDown: (details) => _updateHue(details.localPosition, size),
              onPanUpdate: (details) => _updateHue(details.localPosition, size),
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: Stack(
                  children: [
                    CustomPaint(size: size, painter: const _HueBarPainter()),
                    Positioned(
                      left: (_hue / 360 * size.width).clamp(
                        8.0,
                        size.width - 8,
                      ),
                      top: 1,
                      child: const IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.black54, blurRadius: 4),
                            ],
                          ),
                          child: SizedBox(width: 18, height: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        const Text(
          'HEX CODE',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _hexController,
          textCapitalization: TextCapitalization.characters,
          onChanged: (value) {
            final color = _captionColorFromHex(value);
            if (color == null) return;
            final hsv = HSVColor.fromColor(color);
            setState(() {
              _hue = hsv.hue;
              _saturation = hsv.saturation;
              _value = hsv.value;
            });
            widget.onLiveChange(color);
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.elevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.secondary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white, width: 1.5),
            ),
          ),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: () => widget.onApply(_color),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text(
              'Apply color',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    ),
  );
}

class _SaturationValuePainter extends CustomPainter {
  const _SaturationValuePainter({required this.hue});
  final double hue;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(
      bounds,
      Paint()..color = HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
    );
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          colors: [Colors.white, Colors.transparent],
        ).createShader(bounds),
    );
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black],
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(covariant _SaturationValuePainter oldDelegate) =>
      oldDelegate.hue != hue;
}

class _HueBarPainter extends CustomPainter {
  const _HueBarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds, const Radius.circular(12)),
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFF4D4D),
            Color(0xFFFFD34E),
            Color(0xFF72E06A),
            Color(0xFF44C7FF),
            Color(0xFF7858FF),
            Color(0xFFFF5EBE),
            Color(0xFFFF4D4D),
          ],
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(covariant _HueBarPainter oldDelegate) => false;
}

Color? _captionColorFromHex(String raw) {
  var value = raw.trim().replaceAll('#', '');
  if (value.length == 6) value = 'FF$value';
  if (value.length != 8) return null;
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? null : Color(parsed);
}

String _captionColorHex(Color color) {
  final value = color
      .toARGB32()
      .toRadixString(16)
      .padLeft(8, '0')
      .toUpperCase();
  return '#${value.substring(2)}';
}

