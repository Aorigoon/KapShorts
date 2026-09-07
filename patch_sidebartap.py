with open('lib/screens/editor_screen.dart', 'r') as f:
    content = f.read()

# Fix duplicate enum
content = content.replace("  aiFit,\n  preview,\n  aiFit,\n  preview,", "  aiFit,\n  preview,")

# Fix sidebarTapHandler scope variables
old_handler_aiFit = """        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context); // pop dialog
          // Mock AI result: set position to center
          updateDesign(design.copyWith(position: CaptionPosition.center, customX: null, customY: null));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI positioned captions to Center (Mock)')));
        });"""

new_handler_aiFit = """        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context); // pop dialog
          final currentDesign = ref.read(captionDesignProvider);
          ref.read(captionDesignProvider.notifier).state = currentDesign.copyWith(position: CaptionPosition.center, customX: null, customY: null);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI positioned captions to Center (Mock)')));
        });"""

content = content.replace(old_handler_aiFit, new_handler_aiFit)

old_handler_preview = """      if (tool == EditorTool.preview) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlatformPreviewScreen(
              controller: controller,
              design: design,
              transcription: transcription ?? project?.transcription,
            ),
          ),
        );
        return;
      }"""

new_handler_preview = """      if (tool == EditorTool.preview) {
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

content = content.replace(old_handler_preview, new_handler_preview)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(content)
