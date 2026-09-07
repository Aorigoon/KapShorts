with open('lib/screens/editor_screen.dart', 'r') as f:
    content = f.read()

# The definition of allFonts is quite large, let's just grab it using regex.
import re
pattern = r"(const allFonts = \[\n.*?FontPreviewChoice.*?\];)"
match = re.search(pattern, content, re.DOTALL)
if match:
    allFonts_def = match.group(1)
    # Remove it from its current location
    content = content.replace(allFonts_def, "")
    
    # Insert it before `if (customColorPage)`
    target = "        if (customColorPage) {"
    content = content.replace(target, allFonts_def + "\n" + target, 1)
else:
    print("Could not find allFonts definition!")

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(content)
