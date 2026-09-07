with open('lib/screens/editor_screen.dart', 'r') as f:
    content = f.read()

import re

# Add _PlatformIcon definition at the bottom of the file
platform_icon_code = """
class _PlatformIcon extends StatelessWidget {
  const _PlatformIcon({required this.icon, required this.label, required this.onTap, super.key});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white12,
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
"""
content += platform_icon_code

# Replace showFullscreenPreview
old_fullscreen = """Future<void> showFullscreenPreview(
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
}"""

new_fullscreen = """Future<void> showFullscreenPreview(
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
  
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select Preview Mode', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 24,
            runSpacing: 24,
            children: [
              _PlatformIcon(
                icon: Icons.video_settings_rounded,
                label: 'Original',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _FullscreenVideoPreview(
                        videoPath: videoPath,
                        transcription: transcription,
                        design: design,
                      ),
                    ),
                  );
                },
              ),
              _PlatformIcon(
                icon: Icons.fullscreen_rounded,
                label: 'Full',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PlatformPreviewScreen(
                        videoPath: videoPath,
                        transcription: transcription,
                        design: design,
                        platform: 'full',
                      ),
                    ),
                  );
                },
              ),
              _PlatformIcon(
                icon: Icons.camera_alt_rounded,
                label: 'Instagram',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PlatformPreviewScreen(
                        videoPath: videoPath,
                        transcription: transcription,
                        design: design,
                        platform: 'reels',
                      ),
                    ),
                  );
                },
              ),
              _PlatformIcon(
                icon: Icons.facebook_rounded,
                label: 'Facebook',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PlatformPreviewScreen(
                        videoPath: videoPath,
                        transcription: transcription,
                        design: design,
                        platform: 'facebook',
                      ),
                    ),
                  );
                },
              ),
              _PlatformIcon(
                icon: Icons.tiktok,
                label: 'TikTok',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PlatformPreviewScreen(
                        videoPath: videoPath,
                        transcription: transcription,
                        design: design,
                        platform: 'tiktok',
                      ),
                    ),
                  );
                },
              ),
              _PlatformIcon(
                icon: Icons.play_arrow_rounded,
                label: 'Shorts',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PlatformPreviewScreen(
                        videoPath: videoPath,
                        transcription: transcription,
                        design: design,
                        platform: 'shorts',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}"""

content = content.replace(old_fullscreen, new_fullscreen)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(content)
