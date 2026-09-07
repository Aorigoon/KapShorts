with open('lib/screens/editor_screen.dart', 'r') as f:
    content = f.read()

import re

# Fix 1: Remove `this.onDesignUpdate` from `HighlightWordOverview`
old_highlight = """  const HighlightWordOverview({
    required this.transcription,
    required this.onWordToggled,
    this.onDesignUpdate,
    super.key,
  });"""

new_highlight = """  const HighlightWordOverview({
    required this.transcription,
    required this.onWordToggled,
    super.key,
  });"""

content = content.replace(old_highlight, new_highlight)

# Fix 2: Remove `final ValueChanged<CaptionDesign>? onDesignUpdate;` from `_CaptionOverlay`
old_overlay = """  final CaptionDesign design;
  final void Function(int globalIndex)? onWordToggled;
  final ValueChanged<CaptionDesign>? onDesignUpdate;
  final void Function(Offset delta)? onDrag;"""

new_overlay = """  final CaptionDesign design;
  final void Function(int globalIndex)? onWordToggled;
  final void Function(Offset delta)? onDrag;"""

content = content.replace(old_overlay, new_overlay)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(content)
