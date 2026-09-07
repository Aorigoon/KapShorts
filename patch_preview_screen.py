with open('lib/screens/editor_screen.dart', 'r') as f:
    content = f.read()

import re

# Fix sidebarTapHandler to pass videoPath instead of controller
old_preview_tap = """      if (tool == EditorTool.preview) {
        final currentDesign = ref.read(captionDesignProvider);
        final currentController = ref.read(videoPlayerProvider);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlatformPreviewScreen(
              controller: currentController,
              design: currentDesign,
              transcription: transcription ?? project?.transcription,
            ),
          ),
        );
        return;
      }"""

new_preview_tap = """      if (tool == EditorTool.preview) {
        final currentDesign = ref.read(captionDesignProvider);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlatformPreviewScreen(
              videoPath: project?.videoPath ?? '',
              design: currentDesign,
              transcription: transcription ?? project?.transcription,
            ),
          ),
        );
        return;
      }"""

content = content.replace(old_preview_tap, new_preview_tap)

# Fix PlatformPreviewScreen definition
old_preview_class = """class PlatformPreviewScreen extends StatelessWidget {
  const PlatformPreviewScreen({
    super.key,
    required this.controller,
    required this.design,
    required this.transcription,
  });

  final VideoPlayerController? controller;
  final CaptionDesign design;
  final Map<String, dynamic>? transcription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (controller != null)
            GestureDetector(
              onTap: () {
                if (controller!.value.isPlaying) {
                  controller!.pause();
                } else {
                  controller!.play();
                }
              },
              child: VideoPlayer(controller!),
            ),
          if (controller != null)
            AnimatedBuilder(
              animation: controller!,
              builder: (context, _) => _CaptionOverlay(
                transcription: transcription,
                position: controller!.value.position,
                design: design,
              ),
            ),"""

new_preview_class = """class PlatformPreviewScreen extends StatefulWidget {
  const PlatformPreviewScreen({
    super.key,
    required this.videoPath,
    required this.design,
    required this.transcription,
  });

  final String videoPath;
  final CaptionDesign design;
  final Map<String, dynamic>? transcription;

  @override
  State<PlatformPreviewScreen> createState() => _PlatformPreviewScreenState();
}

class _PlatformPreviewScreenState extends State<PlatformPreviewScreen> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.videoPath.isNotEmpty) {
      _controller = createVideoController(widget.videoPath);
      _controller!.initialize().then((_) {
        _controller!.setLooping(true);
        _controller!.play();
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            GestureDetector(
              onTap: () {
                if (_controller!.value.isPlaying) {
                  _controller!.pause();
                } else {
                  _controller!.play();
                }
              },
              child: VideoPlayer(_controller!),
            ),
          if (_controller != null && _controller!.value.isInitialized)
            AnimatedBuilder(
              animation: _controller!,
              builder: (context, _) => _CaptionOverlay(
                transcription: widget.transcription,
                position: _controller!.value.position,
                design: widget.design,
              ),
            ),"""

content = content.replace(old_preview_class, new_preview_class)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(content)
