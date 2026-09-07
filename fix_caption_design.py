with open('lib/core/models/caption_design.dart', 'r') as f:
    text = f.read()

text = text.replace("    customY: customY ?? this.customY,\n      customScale: customScale ?? this.customScale,\n    this.customScale,", "    customY: customY ?? this.customY,\n    customScale: customScale ?? this.customScale,")

with open('lib/core/models/caption_design.dart', 'w') as f:
    f.write(text)
