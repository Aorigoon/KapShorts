with open('lib/screens/editor_screen.dart', 'r') as f:
    content = f.read()

import re

# Add onDesignUpdate to the constructor arguments
content = re.sub(
    r"(this\.onWordToggled,\n\s+)(super\.key,)",
    r"\1this.onDesignUpdate,\n    \2",
    content
)

# Add onDesignUpdate to the fields
content = re.sub(
    r"(final void Function\(int globalIndex\)\? onWordToggled;)",
    r"\1\n  final ValueChanged<CaptionDesign>? onDesignUpdate;",
    content
)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(content)
