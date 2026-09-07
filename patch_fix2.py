with open('lib/screens/editor_screen.dart', 'r') as f:
    content = f.read()

# Fix 1: const SizedBox(height: 18); to const SizedBox(height: 18),
content = content.replace("const SizedBox(height: 18);", "const SizedBox(height: 18),")

# Fix 2: allFonts undefined. Let's see where allFonts is defined in the file.
import re
# The allFonts is likely just a list of CaptionFont.values.
# Let's replace `allFonts` with `CaptionFont.values` in the choosingActiveFont block.
content = content.replace("itemCount: allFonts.length,", "itemCount: CaptionFont.values.length,")
content = content.replace("allFonts[index].font", "CaptionFont.values[index]")
content = content.replace("choice: allFonts[index]", "choice: FontChoice(font: CaptionFont.values[index], name: CaptionFont.values[index].name)")

# Wait, `allFonts` is a list of `FontChoice` objects, not just enum values.
# Let's see how `allFonts` is defined for highlight font.
# It's probably `final allFonts = ...`
