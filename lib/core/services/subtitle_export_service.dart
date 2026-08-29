import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

import '../models/caption_models.dart';

class SubtitleExportService {
  Future<File> writeSrt({required String name, required List<CaptionWord> words}) async {
    final file = await _outputFile(name, 'srt');
    await file.writeAsString(_toSrt(words));
    return file;
  }

  Future<File> writeVtt({required String name, required List<CaptionWord> words}) async {
    final file = await _outputFile(name, 'vtt');
    await file.writeAsString('WEBVTT\n\n${_toSrt(words).replaceAll(',', '.')}');
    return file;
  }

  Future<File> writeAss({required String name, required List<CaptionWord> words, required CaptionStyle style}) async {
    final file = await _outputFile(name, 'ass');
    await file.writeAsString(_toAss(words, style));
    return file;
  }

  Future<File> burnCaptions({
    required String inputVideoPath,
    required File assFile,
    required String outputName,
  }) async {
    final output = await _outputFile(outputName, 'mp4');
    final command = '-y -i "${_escape(inputVideoPath)}" -vf "ass=${_escape(assFile.path)}" -c:a copy "${_escape(output.path)}"';
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();
    if (!ReturnCode.isSuccess(returnCode)) {
      throw StateError('Captioned video render complete nahi ho saka. FFmpeg return code: $returnCode');
    }
    return output;
  }

  Future<File> _outputFile(String name, String extension) async {
    final directory = await getApplicationDocumentsDirectory();
    final cleanName = name.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return File('${directory.path}/${cleanName}_${DateTime.now().millisecondsSinceEpoch}.$extension');
  }

  String _toSrt(List<CaptionWord> words) {
    return List.generate(words.length, (index) {
      final word = words[index];
      return '${index + 1}\n${_srtTime(word.startMs)} --> ${_srtTime(word.endMs)}\n${word.text.trim()}\n';
    }).join('\n');
  }

  String _toAss(List<CaptionWord> words, CaptionStyle style) {
    final alignment = switch (style.position) {
      CaptionPosition.top => 8,
      CaptionPosition.center => 5,
      CaptionPosition.bottom => 2,
    };
    final outline = style.strokeWidth.round();
    final header = '''[Script Info]
ScriptType: v4.00+
PlayResX: 1080
PlayResY: 1920

[V4+ Styles]
Format: Name,Fontname,Fontsize,PrimaryColour,SecondaryColour,OutlineColour,BackColour,Bold,Italic,Underline,StrikeOut,ScaleX,ScaleY,Spacing,Angle,BorderStyle,Outline,Shadow,Alignment,MarginL,MarginR,MarginV,Encoding
Style: Default,${style.fontFamily},${style.fontSize.round()},&H00${style.textColor},&H00${style.activeColor},&H00000000,&H66000000,${style.fontWeight >= 700 ? -1 : 0},0,0,0,100,100,0,0,1,$outline,0,$alignment,64,64,130,1

[Events]
Format: Layer,Start,End,Style,Name,MarginL,MarginR,MarginV,Effect,Text
''';
    final events = words.map((word) {
      final escaped = word.text.replaceAll('{', '\\{').replaceAll('}', '\\}').replaceAll('\\', '\\\\');
      final duration = ((word.endMs - word.startMs) / 10).round().clamp(1, 9999);
      final karaoke = style.animation == CaptionAnimation.karaokeFill ? '{\\k$duration}' : '';
      return 'Dialogue: 0,${_assTime(word.startMs)},${_assTime(word.endMs)},Default,,0,0,0,,$karaoke$escaped';
    }).join('\n');
    return '$header$events\n';
  }

  String _srtTime(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(duration.inHours)}:${two(duration.inMinutes.remainder(60))}:${two(duration.inSeconds.remainder(60))},${(duration.inMilliseconds.remainder(1000)).toString().padLeft(3, '0')}';
  }

  String _assTime(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    return '${duration.inHours}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}.${(duration.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0')}';
  }

  String _escape(String value) => value.replaceAll('\\', '\\\\').replaceAll(':', '\\:').replaceAll("'", "\\'");
}
