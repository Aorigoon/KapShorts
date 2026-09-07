with open('lib/screens/editor_screen.dart', 'r') as f:
    content = f.read()

import re
# Remove aiFit and preview from EditorTool enum
content = re.sub(r"  aiFit,\n  preview,\n", "", content)

# Remove aiFit logic from sidebarTapHandler
aiFit_logic = r"      if \(tool == EditorTool\.aiFit\) \{.*?(?:return;\n      \})"
content = re.sub(aiFit_logic, "", content, flags=re.DOTALL)

# Remove preview logic from sidebarTapHandler
preview_logic = r"      if \(tool == EditorTool\.preview\) \{.*?(?:return;\n      \})"
content = re.sub(preview_logic, "", content, flags=re.DOTALL)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(content)
