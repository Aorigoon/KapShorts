with open('lib/screens/editor_screen.dart', 'r') as f:
    content = f.read()

# Fix 1: const SizedBox(height: 18);
content = content.replace("const SizedBox(height: 18);", "const SizedBox(height: 18),")

# Fix 2: allFonts scope
import re
pattern = r"(const allFonts = \[\n.*?FontPreviewChoice.*?\];)"
match = re.search(pattern, content, re.DOTALL)
if match:
    allFonts_def = match.group(1)
    content = content.replace(allFonts_def, "")
    target = "        if (customColorPage) {"
    content = content.replace(target, allFonts_def + "\n" + target, 1)

# Fix 3: updateDesign missing in _CaptionTextEditorScreenState
# This is inside `class _CaptionTextEditorScreenState` which is around line 2890
# We want to replace `updateDesign(design.copyWith` with `ref.read(captionDesignProvider.notifier).state = design.copyWith` ONLY for that specific block.

old_drag = """                            onDrag: (delta) {
                              double currentX = design.customX ?? 24.0;
                              double currentY = design.customY ?? (design.position == CaptionPosition.top ? 34.0 : design.position == CaptionPosition.bottom ? 140.0 : 80.0);
                              updateDesign(design.copyWith(customX: currentX + delta.dx, customY: currentY + delta.dy));
                            },"""

new_drag = """                            onDrag: (delta) {
                              double currentX = design.customX ?? 24.0;
                              double currentY = design.customY ?? (design.position == CaptionPosition.top ? 34.0 : design.position == CaptionPosition.bottom ? 140.0 : 80.0);
                              ref.read(captionDesignProvider.notifier).state = design.copyWith(customX: currentX + delta.dx, customY: currentY + delta.dy);
                            },"""

content = content.replace(old_drag, new_drag)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(content)
