import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';
import '../core/providers.dart';
import '../core/utils.dart';
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String output = 'Caption file (.srt)';
  bool exporting = false;

  Future<void> export() async {
    final project = ref.read(projectsProvider).selected;
    if (project == null) {
      showAppMessage(context, 'Open a project before exporting.');
      return;
    }
    setState(() => exporting = true);
    try {
      if (output == 'Caption file (.srt)') {
        final srt = _buildCaptionSrt(project.transcription);
        if (srt.isEmpty) {
          if (mounted)
            showAppMessage(
              context,
              'Generate captions before exporting an SRT file.',
            );
          return;
        }
        final target = await FilePicker.saveFile(
          fileName: '${_exportStem(project.name)}.srt',
          bytes: Uint8List.fromList(utf8.encode(srt)),
          mimeType: 'application/x-subrip',
          dialogTitle: 'Save caption file',
          type: FileType.custom,
          allowedExtensions: const ['srt'],
        );
        if (mounted) {
          showAppMessage(
            context,
            target == null
                ? 'Caption save canceled.'
                : 'Caption file saved successfully.',
          );
        }
      } else {
        final source = File(project.videoPath);
        if (!source.existsSync()) {
          if (mounted)
            showAppMessage(context, 'Original video file is unavailable.');
          return;
        }
        final root =
            await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
        final exports = Directory('${root.path}/SubReel Exports');
        await exports.create(recursive: true);
        await source.copy('${exports.path}/${_exportStem(project.name)}.mp4');
        if (mounted)
          showAppMessage(
            context,
            'Original video copy saved in SubReel Exports.',
          );
      }
    } catch (_) {
      if (mounted)
        showAppMessage(
          context,
          'Export could not be completed. Please try again.',
        );
    } finally {
      if (mounted) setState(() => exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: AppColors.canvas,
      foregroundColor: Colors.white,
      title: Text(
        'Export',
        style: GoogleFonts.syne(fontWeight: FontWeight.w700),
      ),
      centerTitle: false,
    ),
    body: Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose output',
            style: GoogleFonts.syne(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ExportOption(
                  label: 'Caption SRT',
                  icon: Icons.subtitles_outlined,
                  selected: output == 'Caption file (.srt)',
                  onTap: () => setState(() => output = 'Caption file (.srt)'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ExportOption(
                  label: 'Video copy',
                  icon: Icons.movie_outlined,
                  selected: output == 'Video copy (.mp4)',
                  onTap: () => setState(() => output = 'Video copy (.mp4)'),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            output == 'Caption file (.srt)'
                ? 'Save timed captions as a standard .srt subtitle file.'
                : 'Save a local copy of the original imported video.',
            style: const TextStyle(
              color: AppColors.secondary,
              height: 1.45,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: exporting ? null : export,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                disabledBackgroundColor: AppColors.elevated,
                shape: const StadiumBorder(),
              ),
              child: exporting
                  ? const SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      output == 'Caption file (.srt)'
                          ? 'Save caption file'
                          : 'Save video copy',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    ),
  );
}

String _exportStem(String name) {
  final clean = name.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
  return clean.isEmpty ? 'subreel_export' : clean;
}

String _buildCaptionSrt(Map<String, dynamic>? transcription) {
  final groups = captionGroups(resolveCaptionWords(transcription), 5);
  if (groups.isEmpty) return '';
  return groups.indexed
      .map((entry) {
        final index = entry.$1 + 1;
        final group = entry.$2;
        return '$index\n${_srtTime(group.first.start)} --> ${_srtTime(group.last.end)}\n${group.map((word) => word.text).join(' ')}\n';
      })
      .join('\n');
}

String _srtTime(double seconds) {
  final totalMs = (seconds.clamp(0, double.infinity) * 1000).round();
  final hours = totalMs ~/ 3600000;
  final minutes = (totalMs % 3600000) ~/ 60000;
  final secs = (totalMs % 60000) ~/ 1000;
  final millis = totalMs % 1000;
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')},${millis.toString().padLeft(3, '0')}';
}

class ExportOption extends StatelessWidget {
  const ExportOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    super.key,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      height: 112,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? Colors.white : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: selected ? Colors.white : AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: selected ? Colors.black : Colors.white),
          const Spacer(),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: selected ? Colors.black : Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

