with open('lib/screens/editor_screen.dart', 'r') as f:
    content = f.read()

import re

# Remove playOverlay declaration
playOverlay_decl = r"    final playOverlay = Center\(\n      child: AnimatedOpacity\([\s\S]*?    \);\n"
content = re.sub(playOverlay_decl, "", content)

# Remove playOverlay from frameCanvas
content = content.replace("        playOverlay,\n", "")

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(content)
