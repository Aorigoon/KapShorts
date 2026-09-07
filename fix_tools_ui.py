with open('lib/screens/editor_screen.dart', 'r') as f:
    text = f.read()

import re

text = re.sub(r"      \(EditorTool\.aiFit, Icons\.auto_awesome_rounded, 'AI Fit'\),\n", "", text)
text = re.sub(r"      \(EditorTool\.preview, Icons\.preview_rounded, 'Preview'\),\n", "", text)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(text)
