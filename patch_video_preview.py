with open('lib/screens/editor_screen.dart', 'r') as f:
    content = f.read()

# 1. Update VideoPreviewPlayer constructor and fields
old_constructor = """class VideoPreviewPlayer extends StatefulWidget {
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
    this.onWordToggled,
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
  final void Function(int globalIndex)? onWordToggled;"""

new_constructor = """class VideoPreviewPlayer extends StatefulWidget {
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
    this.onWordToggled,
    this.onDesignUpdate,
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
  final void Function(int globalIndex)? onWordToggled;
  final ValueChanged<CaptionDesign>? onDesignUpdate;"""

content = content.replace(old_constructor, new_constructor)

# 2. Update VideoPreviewPlayer usage in _EditorScreenState (line 328)
old_usage = """                          child: VideoPreviewPlayer(
                            videoPath: project?.videoPath ?? '',
                            transcription: transcription ?? project?.transcription,
                            design: design,
                            playback: _playback,
                            timelineSeek: _timelineSeek,
                            playbackCommand: _playbackCommand,
                            playbackSpeed: _playbackSpeed,
                            previewAspect: _previewAspect,
                            onReplaceVideo: () => replaceVideoForProject(context, ref),
                          ),"""

new_usage = """                          child: VideoPreviewPlayer(
                            videoPath: project?.videoPath ?? '',
                            transcription: transcription ?? project?.transcription,
                            design: design,
                            playback: _playback,
                            timelineSeek: _timelineSeek,
                            playbackCommand: _playbackCommand,
                            playbackSpeed: _playbackSpeed,
                            previewAspect: _previewAspect,
                            onReplaceVideo: () => replaceVideoForProject(context, ref),
                            onDesignUpdate: (d) => ref.read(captionDesignProvider.notifier).state = d,
                          ),"""

content = content.replace(old_usage, new_usage)

# 3. Add onDrag to _CaptionOverlay inside _VideoPreviewPlayerState (around line 3463)
old_overlay = """        _CaptionOverlay(
          transcription: widget.transcription,
          position: position,
          design: widget.design,
          onWordToggled: widget.onWordToggled,
        ),"""

new_overlay = """        _CaptionOverlay(
          transcription: widget.transcription,
          position: position,
          design: widget.design,
          onWordToggled: widget.onWordToggled,
          onDrag: widget.onDesignUpdate == null ? null : (delta) {
            final currentX = widget.design.customX ?? 24.0;
            final currentY = widget.design.customY ?? (widget.design.position == CaptionPosition.top ? 34.0 : widget.design.position == CaptionPosition.bottom ? 140.0 : 80.0);
            widget.onDesignUpdate!(widget.design.copyWith(customX: currentX + delta.dx, customY: currentY + delta.dy));
          },
        ),"""

content = content.replace(old_overlay, new_overlay)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(content)
