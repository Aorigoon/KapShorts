import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/caption_design.dart';
import 'app_colors.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

VideoPlayerController createVideoController(String path) {
  if (kIsWeb) {
    return VideoPlayerController.networkUrl(Uri.parse(path));
  }
  return VideoPlayerController.file(File(path));
}

bool videoPathAvailable(String path) {
  return path.isNotEmpty && (kIsWeb || File(path).existsSync());
}

class WorkerEndpoint {
  static final uri = kIsWeb
      ? Uri.base
      : Uri.parse('https://subreel-gemini-proxy.myimage.workers.dev');
}

Future<File?> createReelFrame(String videoPath, int timeMs) async {
  if (kIsWeb || !videoPathAvailable(videoPath)) return null;
  final directory = await getTemporaryDirectory();
  final output = File(
    '${directory.path}/subreel_reel_v2_${videoPath.hashCode}_$timeMs.jpg',
  );
  if (output.existsSync()) return output;
  final safeInput = videoPath.replaceAll('"', r'\"');
  final safeOutput = output.path.replaceAll('"', r'\"');
  await FFmpegKit.execute(
    '-ss ${(timeMs / 1000).toStringAsFixed(3)} -i "$safeInput" -frames:v 1 -vf scale=360:-2 -q:v 2 -y "$safeOutput"',
  );
  return output.existsSync() ? output : null;
}

void showAppMessage(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: AppColors.elevated,
        behavior: SnackBarBehavior.floating,
      ),
    );

TextStyle captionTextStyle(
  CaptionDesign design, {
  Color? color,
  double? fontSize,
}) {
  final base = switch (design.font) {
    CaptionFont.poppins => GoogleFonts.poppins(),
    CaptionFont.inter => GoogleFonts.inter(),
    CaptionFont.anton => GoogleFonts.anton(),
    CaptionFont.syne => GoogleFonts.syne(),
    CaptionFont.dmSans => GoogleFonts.dmSans(),
    CaptionFont.jetBrainsMono => GoogleFonts.jetBrainsMono(),
    CaptionFont.baloo2 => GoogleFonts.baloo2(),
    CaptionFont.montserrat => GoogleFonts.montserrat(),
    CaptionFont.manrope => GoogleFonts.manrope(),
    CaptionFont.playfair => GoogleFonts.playfairDisplay(),
    CaptionFont.caveat => GoogleFonts.caveat(),
    CaptionFont.permanentMarker => GoogleFonts.permanentMarker(),
    CaptionFont.bungee => GoogleFonts.bungee(),
    CaptionFont.spaceGrotesk => GoogleFonts.spaceGrotesk(),
    CaptionFont.pixel => GoogleFonts.pressStart2p(),
    CaptionFont.abril => GoogleFonts.abrilFatface(),
    CaptionFont.lobster => GoogleFonts.lobster(),
    CaptionFont.oswald => GoogleFonts.oswald(),
    CaptionFont.righteous => GoogleFonts.righteous(),
    CaptionFont.archivoBlack => GoogleFonts.archivoBlack(),
    CaptionFont.rubikMono => GoogleFonts.rubikMonoOne(),
    CaptionFont.chivo => GoogleFonts.chivo(),
    CaptionFont.comfortaa => GoogleFonts.comfortaa(),
    CaptionFont.cormorant => GoogleFonts.cormorantGaramond(),
    CaptionFont.fredoka => GoogleFonts.fredoka(),
    CaptionFont.leagueGothic => GoogleFonts.leagueGothic(),
    CaptionFont.lilitaOne => GoogleFonts.lilitaOne(),
    CaptionFont.pacifico => GoogleFonts.pacifico(),
    CaptionFont.ptSansNarrow => GoogleFonts.ptSansNarrow(),
    CaptionFont.rubikWetPaint => GoogleFonts.rubikWetPaint(),
    CaptionFont.rye => GoogleFonts.rye(),
    CaptionFont.secularOne => GoogleFonts.secularOne(),
    CaptionFont.staatliches => GoogleFonts.staatliches(),
    CaptionFont.truculenta => GoogleFonts.truculenta(),
    CaptionFont.tiltWarp => GoogleFonts.tiltWarp(),
    CaptionFont.sriracha => GoogleFonts.sriracha(),
  };
  final outline = design.outlineWidth <= 0
      ? <Shadow>[]
      : [
          for (final offset in const [
            Offset(-1, -1),
            Offset(1, -1),
            Offset(-1, 1),
            Offset(1, 1),
          ])
            Shadow(
              color: Colors.black,
              blurRadius: 0,
              offset: offset * (design.outlineWidth / 1.5),
            ),
        ];
  final shadows = design.glow
      ? [
          Shadow(
            color: (color ?? design.color).withValues(alpha: .78),
            blurRadius: 14,
          ),
          Shadow(
            color: (color ?? design.color).withValues(alpha: .34),
            blurRadius: 28,
          ),
          ...outline,
        ]
      : outline;
  return base.copyWith(
    fontSize: fontSize ?? design.size,
    height: 1.04,
    fontWeight: design.weight,
    color: color ?? design.color,
    letterSpacing: design.letterSpacing,
    shadows: shadows,
  );
}

class TimedCaptionWord {
  const TimedCaptionWord({
    required this.text,
    required this.start,
    required this.end,
  });
  final String text;
  final double start;
  final double end;
}

List<TimedCaptionWord> resolveCaptionWords(
  Map<String, dynamic>? transcription,
) {
  final rawSegments = transcription?['segments'];
  final segments = rawSegments is List
      ? rawSegments.whereType<Map>().toList()
      : <Map>[];
  final rawWords = transcription?['words'];
  final timedWords = <TimedCaptionWord>[];
  if (rawWords is List) {
    for (final item in rawWords.whereType<Map>()) {
      final text = item['text'] as String? ?? '';
      final start = (item['start'] as num?)?.toDouble();
      final end = (item['end'] as num?)?.toDouble();
      if (text.trim().isNotEmpty &&
          start != null &&
          end != null &&
          end >= start) {
        timedWords.add(
          TimedCaptionWord(text: text.trim(), start: start, end: end),
        );
      }
    }
  }
  if (timedWords.isNotEmpty && _wordTimesMatchSegments(timedWords, segments)) {
    timedWords.sort((a, b) => a.start.compareTo(b.start));
    return timedWords;
  }
  return _wordsFromSegments(segments);
}

List<List<TimedCaptionWord>> captionGroups(
  List<TimedCaptionWord> words,
  int maxWords,
) {
  if (words.isEmpty) return <List<TimedCaptionWord>>[];
  final limit = maxWords < 2 ? 2 : maxWords;
  final groups = <List<TimedCaptionWord>>[];
  var current = <TimedCaptionWord>[];
  for (final word in words) {
    final hasNaturalPause =
        current.isNotEmpty && word.start - current.last.end > .85;
    if (current.isNotEmpty && (current.length >= limit || hasNaturalPause)) {
      groups.add(current);
      current = <TimedCaptionWord>[];
    }
    current.add(word);
  }
  if (current.isNotEmpty) groups.add(current);
  return groups;
}

bool _wordTimesMatchSegments(
  List<TimedCaptionWord> words,
  List<Map> segments,
) {
  if (segments.isEmpty) return words.isNotEmpty;
  var wordIndex = 0;
  for (final segment in segments) {
    final tokens = (segment['text'] as String? ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    final start = (segment['start'] as num?)?.toDouble() ?? 0;
    final end = (segment['end'] as num?)?.toDouble() ?? start;
    for (final token in tokens) {
      if (wordIndex >= words.length) return false;
      final word = words[wordIndex++];
      if (_normaliseCaptionText(token) != _normaliseCaptionText(word.text) ||
          word.start < start - .25 ||
          word.end > end + .4) {
        return false;
      }
    }
  }
  return wordIndex == words.length;
}

List<TimedCaptionWord> _wordsFromSegments(List<Map> segments) {
  final timedWords = <TimedCaptionWord>[];
  for (final item in segments) {
    final text = item['text'] as String? ?? '';
    final start = (item['start'] as num?)?.toDouble() ?? 0;
    final end = (item['end'] as num?)?.toDouble() ?? start;
    final tokens = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (tokens.isEmpty) continue;
    final duration =
        ((end - start).clamp(.12, double.infinity)) / tokens.length;
    for (var index = 0; index < tokens.length; index++) {
      final wordStart = start + (duration * index);
      timedWords.add(
        TimedCaptionWord(
          text: tokens[index],
          start: wordStart,
          end: index == tokens.length - 1 ? end : wordStart + duration,
        ),
      );
    }
  }
  return timedWords;
}

String _normaliseCaptionText(String value) =>
    value.toLowerCase().replaceAll(RegExp(r"[^a-z0-9\u0600-\u06ff]+"), '');



class CaptionWord extends StatelessWidget {
  const CaptionWord({
    required this.text,
    required this.style,
    required this.isActive,
    required this.effect,
    required this.wordProgress,
    required this.textSize,
    required this.doubleLayer,
    required this.hardShadow,
  });
  final String text;
  final TextStyle style;
  final bool isActive;
  final CaptionEffect effect;
  final double wordProgress;
  final double textSize;
  final bool doubleLayer;
  final bool hardShadow;

  @override
  Widget build(BuildContext context) {
    final popScale =
        (effect == CaptionEffect.pop || effect == CaptionEffect.stagger) &&
            isActive
        ? .90 + (.18 * (wordProgress / .3).clamp(0.0, 1.0))
        : effect == CaptionEffect.pulse && isActive
        ? 1.0 + (.08 * (1 - wordProgress).clamp(0.0, 1.0))
        : 1.0;
    final bounceLift = effect == CaptionEffect.bounce && isActive
        ? -textSize * (.10 + (.10 * (1 - wordProgress)))
        : 0.0;
    final drift = effect == CaptionEffect.drift && isActive
        ? textSize * (.14 - (wordProgress * .14))
        : 0.0;
    final mainText = Text(text, textAlign: TextAlign.center, style: style);
    return Transform.translate(
      offset: Offset(0, bounceLift + drift),
      child: Transform.scale(
        scale: popScale,
        child: hardShadow
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: textSize * .09,
                    top: textSize * .10,
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: style.copyWith(color: Colors.black),
                    ),
                  ),
                  mainText,
                ],
              )
            : doubleLayer
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 4,
                    top: 4,
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: style.copyWith(
                        color: style.color?.withValues(alpha: .35),
                      ),
                    ),
                  ),
                  mainText,
                ],
              )
            : mainText,
      ),
    );
  }
}
