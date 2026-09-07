with open('lib/screens/editor_screen.dart', 'r') as f:
    content = f.read()

import re

# Update PlatformPreviewScreen constructor and fields
old_preview_class = """class PlatformPreviewScreen extends StatefulWidget {
  const PlatformPreviewScreen({
    super.key,
    required this.videoPath,
    required this.design,
    required this.transcription,
  });

  final String videoPath;
  final CaptionDesign design;
  final Map<String, dynamic>? transcription;"""

new_preview_class = """class PlatformPreviewScreen extends StatefulWidget {
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
  final String platform;"""

content = content.replace(old_preview_class, new_preview_class)

# Update build method mock UI
old_ui_regex = r"          // Mock TikTok/Reels UI overlay.*?\]\n      \),\n    \);\n  \}\n\}"
new_ui = """          // Mock UI overlays based on platform
          if (widget.platform == 'reels' || widget.platform == 'facebook') ...[
            Positioned(
              right: 12,
              bottom: 120,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_outline_rounded, color: Colors.white, size: 32, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
                  const SizedBox(height: 6),
                  const Text('1.2M', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                  const SizedBox(height: 18),
                  const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 30, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
                  const SizedBox(height: 6),
                  const Text('4,321', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                  const SizedBox(height: 18),
                  const Icon(Icons.send_outlined, color: Colors.white, size: 30, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
                  const SizedBox(height: 6),
                  const Text('Share', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                  const SizedBox(height: 18),
                  const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 30, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
                  const SizedBox(height: 18),
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[800],
                    ),
                    child: const Icon(Icons.music_note, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 12,
              bottom: 30,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      const Text('KapShot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(4)),
                        child: const Text('Follow', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Previewing video with KapShot captions! #reels #kapshot', 
                    style: TextStyle(color: Colors.white, fontSize: 14, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.music_note_rounded, color: Colors.white, size: 14, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
                      const SizedBox(width: 6),
                      const Text('KapShot Original Audio', style: TextStyle(color: Colors.white, fontSize: 13, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                    ],
                  ),
                ],
              ),
            ),
          ] else if (widget.platform == 'shorts') ...[
            Positioned(
              right: 12,
              bottom: 120,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.thumb_up_alt_rounded, color: Colors.white, size: 32, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
                  const SizedBox(height: 6),
                  const Text('1.2M', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                  const SizedBox(height: 20),
                  const Icon(Icons.thumb_down_alt_rounded, color: Colors.white, size: 32, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
                  const SizedBox(height: 6),
                  const Text('Dislike', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                  const SizedBox(height: 20),
                  const Icon(Icons.comment_rounded, color: Colors.white, size: 32, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
                  const SizedBox(height: 6),
                  const Text('4K', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                  const SizedBox(height: 20),
                  const Icon(Icons.share_rounded, color: Colors.white, size: 32, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
                  const SizedBox(height: 6),
                  const Text('Share', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                ],
              ),
            ),
            Positioned(
              left: 12,
              bottom: 40,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      const Text('@KapShot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
                        child: const Text('Subscribe', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Testing YouTube Shorts Preview in KapShot! #shorts', 
                    style: TextStyle(color: Colors.white, fontSize: 14, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ] else if (widget.platform == 'tiktok') ...[
            Positioned(
              right: 12,
              bottom: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Icon(Icons.favorite_rounded, color: Colors.white, size: 36, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
                  const SizedBox(height: 6),
                  const Text('1.2M', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                  const SizedBox(height: 20),
                  const Icon(Icons.comment_rounded, color: Colors.white, size: 36, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
                  const SizedBox(height: 6),
                  const Text('4,321', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                  const SizedBox(height: 20),
                  const Icon(Icons.bookmark_rounded, color: Colors.white, size: 36, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
                  const SizedBox(height: 6),
                  const Text('Save', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                  const SizedBox(height: 20),
                  const Icon(Icons.reply_rounded, color: Colors.white, size: 36, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
                  const SizedBox(height: 6),
                  const Text('Share', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.music_note, color: Colors.black),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 12,
              bottom: 30,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('@KapShot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                  const SizedBox(height: 8),
                  const Text('TikTok preview with KapShot! #tiktok #kapshot', 
                    style: TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.music_note_rounded, color: Colors.white, size: 16, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
                      const SizedBox(width: 8),
                      const Text('Original audio - KapShot', style: TextStyle(color: Colors.white, fontSize: 13, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                    ],
                  ),
                ],
              ),
            ),
          ],
          
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}"""

content = re.sub(old_ui_regex, new_ui, content, flags=re.DOTALL)

# Video Stretches Fix
old_video = """              child: VideoPlayer(_controller!),"""
new_video = """              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),"""
content = content.replace(old_video, new_video)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(content)
