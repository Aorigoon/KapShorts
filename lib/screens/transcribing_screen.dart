import '../core/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui' show ImageFilter;
import 'dart:math' as math;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';
import '../core/providers.dart';
import '../core/services/worker_transcription_service.dart';
class TranscribingScreen extends ConsumerStatefulWidget {
  const TranscribingScreen({super.key});

  @override
  ConsumerState<TranscribingScreen> createState() => _TranscribingScreenState();
}

class _TranscribingScreenState extends ConsumerState<TranscribingScreen>
    with SingleTickerProviderStateMixin {
  int progress = 8;
  String? failure;
  Timer? progressTimer;
  Timer? improvementTaglineTimer;
  int improvementTaglineIndex = 0;
  int lateProgressTicks = 0;
  VideoPlayerController? previewController;
  late final AnimationController motionController;

  @override
  void initState() {
    super.initState();
    motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _loadPreview();
    Future.microtask(_transcribe);
  }

  Future<void> _loadPreview() async {
    final path = ref.read(pendingVideoProvider)?.path;
    if (path == null || path.isEmpty) return;
    final controller = createVideoController(path);
    try {
      await controller.initialize();
      await controller.setVolume(0);
      await controller.setLooping(true);
      await controller.play();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() => previewController = controller);
    } catch (_) {
      controller.dispose();
    }
  }

  void _startProgressMotion() {
    progressTimer?.cancel();
    improvementTaglineTimer?.cancel();
    progressTimer = Timer.periodic(const Duration(milliseconds: 360), (_) {
      if (!mounted || progress >= 99 || failure != null) return;
      setState(() {
        if (progress < 90) {
          progress += 1;
          return;
        }
        lateProgressTicks += 1;
        if (lateProgressTicks >= 6) {
          lateProgressTicks = 0;
          progress = math.min(99, progress + 1);
        }
      });
    });
    improvementTaglineTimer = Timer.periodic(
      const Duration(milliseconds: 1400),
      (_) {
        if (!mounted || progress < 75 || progress >= 99 || failure != null) {
          return;
        }
        setState(() => improvementTaglineIndex++);
      },
    );
  }

  @override
  void dispose() {
    progressTimer?.cancel();
    improvementTaglineTimer?.cancel();
    previewController?.dispose();
    motionController.dispose();
    super.dispose();
  }

  Future<void> _transcribe() async {
    final video = ref.read(pendingVideoProvider);
    if (video == null) {
      setState(
        () => failure =
            'The selected video is unavailable. Please upload it again.',
      );
      return;
    }
    progressTimer?.cancel();
    if (mounted) {
      setState(() {
        failure = null;
        progress = 8;
        improvementTaglineIndex = 0;
        lateProgressTicks = 0;
        lateProgressTicks = 0;
      });
    }
    _startProgressMotion();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      final response = await WorkerTranscriptionService().transcribe(
        workerUri: WorkerEndpoint.uri,
        video: video,
      );
      ref.read(transcriptionProvider.notifier).state = response;
      await ref.read(projectsProvider).saveTranscript(response);
      progressTimer?.cancel();
      improvementTaglineTimer?.cancel();
      if (mounted) {
        setState(() {
          progress = 100;
        });
      }
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (mounted) context.go('/editor');
    } on WorkerTranscriptionException catch (error) {
      progressTimer?.cancel();
      improvementTaglineTimer?.cancel();
      if (mounted) setState(() => failure = error.message);
    }
  }

  String get processingTagline {
    if (progress <= 25) return 'Trimming your video';
    if (progress < 75) return 'Creating captions';
    if (progress >= 99) return 'Finalising captions';
    const improvementTaglines = [
      'Improving captions',
      'Polishing word timing',
      'Refining your captions',
      'Balancing caption breaks',
      'Fine-tuning the wording',
      'Making captions easier to read',
    ];
    return improvementTaglines[improvementTaglineIndex %
        improvementTaglines.length];
  }

  @override
  Widget build(BuildContext context) {
    final revealAmount = .42 + ((progress - 21).clamp(0, 79) / 79) * .28;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _AutomaticLiquidGrid(animation: motionController),
          if (previewController?.value.isInitialized ?? false)
            Align(
              child: Opacity(
                opacity: revealAmount,
                child: Transform.scale(
                  scale: .96 + revealAmount * .08,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      width: 245,
                      child: AspectRatio(
                        aspectRatio: 9 / 16,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: previewController!.value.size.width,
                              height: previewController!.value.size.height,
                              child: VideoPlayer(previewController!),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -.05),
                radius: 1.1,
                colors: [Color(0x271B6A70), Color(0xB5080A0C)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 260,
                    child: Column(
                      children: [
                        Text(
                          failure == null
                              ? 'Your captions are getting ready'
                              : 'Something needs attention',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          failure ?? '$progress% complete',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xCCFFFFFF),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (failure == null)
                          const Text(
                            'Creating captions',
                            style: TextStyle(
                              color: Color(0x99FFFFFF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else
                          TextButton(
                            onPressed: _transcribe,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Retry',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AutomaticLiquidGrid extends StatelessWidget {
  const _AutomaticLiquidGrid({required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _AutomaticLiquidGridPainter(animation),
    child: const SizedBox.expand(),
  );
}

class _AutomaticLiquidGridPainter extends CustomPainter {
  _AutomaticLiquidGridPainter(this.animation) : super(repaint: animation);
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0A1012),
    );
    final t = animation.value * math.pi * 2;
    final coolCenter = Offset(
      size.width * (.28 + math.sin(t) * .08),
      size.height * (.42 + math.cos(t * .7) * .08),
    );
    final warmCenter = Offset(
      size.width * (.71 + math.cos(t * .83) * .07),
      size.height * (.45 + math.sin(t * .66) * .09),
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader =
            RadialGradient(colors: const [Color(0x6047BBC2), Color(0x000A1012)])
                .createShader(
                  Rect.fromCircle(center: coolCenter, radius: size.width * .6),
                ),
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader =
            RadialGradient(colors: const [Color(0x50F09A58), Color(0x000A1012)])
                .createShader(
                  Rect.fromCircle(center: warmCenter, radius: size.width * .58),
                ),
    );
    const cellSize = 19.0;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0x6EFFFFFF);
    for (double y = -cellSize; y <= size.height + cellSize; y += cellSize) {
      for (double x = -cellSize; x <= size.width + cellSize; x += cellSize) {
        canvas.drawCircle(Offset(x, y), .75, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AutomaticLiquidGridPainter oldDelegate) =>
      false;
}

