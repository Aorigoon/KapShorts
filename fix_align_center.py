import re
with open('lib/screens/editor_screen.dart', 'r') as f:
    text = f.read()

old_align = """      child: Align(
        alignment: widget.isCustomPosition ? Alignment.topLeft : ("""

new_align = """      child: Align(
        alignment: widget.isCustomPosition ? Alignment.center : ("""

text = text.replace(old_align, new_align)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(text)
