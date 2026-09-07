with open('lib/screens/editor_screen.dart', 'r') as f:
    content = f.read()

# 1. Update Preview trigger to show a dialog first
old_preview_tap = """      if (tool == EditorTool.preview) {
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

new_preview_tap = """      if (tool == EditorTool.preview) {
        final currentDesign = ref.read(captionDesignProvider);
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
                const Text('Select Platform', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _PlatformIcon(
                      icon: Icons.tiktok,
                      label: 'TikTok',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlatformPreviewScreen(
                              videoPath: project?.videoPath ?? '',
                              design: currentDesign,
                              transcription: transcription ?? project?.transcription,
                              platform: 'tiktok',
                            ),
                          ),
                        );
                      },
                    ),
                    _PlatformIcon(
                      icon: Icons.camera_alt_rounded,
                      label: 'Reels',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlatformPreviewScreen(
                              videoPath: project?.videoPath ?? '',
                              design: currentDesign,
                              transcription: transcription ?? project?.transcription,
                              platform: 'reels',
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlatformPreviewScreen(
                              videoPath: project?.videoPath ?? '',
                              design: currentDesign,
                              transcription: transcription ?? project?.transcription,
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
        return;
      }"""

content = content.replace(old_preview_tap, new_preview_tap)


# 2. Update PlatformPreviewScreen logic to accept platform and change UI accordingly
old_preview_class = """class PlatformPreviewScreen extends StatefulWidget {
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
}"""

new_preview_class = """class _PlatformIcon extends StatelessWidget {
  const _PlatformIcon({required this.icon, required this.label, required this.onTap});
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
            radius: 28,
            backgroundColor: Colors.white12,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class PlatformPreviewScreen extends StatefulWidget {
  const PlatformPreviewScreen({
    super.key,
    required this.videoPath,
    required this.design,
    required this.transcription,
    required this.platform,
  });

  final String videoPath;
  final CaptionDesign design;
  final Map<String, dynamic>? transcription;
  final String platform;

  @override
  State<PlatformPreviewScreen> createState() => _PlatformPreviewScreenState();
}"""

content = content.replace(old_preview_class, new_preview_class)

# 3. Update the UI inside _PlatformPreviewScreenState.build
# Currently the build returns Scaffold(...)

import re

# Replace the stack children for mock UI
old_ui_regex = r"          // Mock TikTok/Reels UI overlay.*?\]\n      \),\n    \);"
# I'll just write a script to replace from "// Mock TikTok" to the end of the build method.
