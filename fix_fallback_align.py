import re
with open('lib/screens/editor_screen.dart', 'r') as f:
    text = f.read()

old_fallback = """               child: Align(
                 alignment: isCustomPosition ? Alignment.topLeft : ("""

new_fallback = """               child: Align(
                 alignment: isCustomPosition ? Alignment.center : ("""

text = text.replace(old_fallback, new_fallback)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(text)
