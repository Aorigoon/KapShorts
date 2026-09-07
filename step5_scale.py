import re

# 1. Update CaptionDesign in lib/core/models/caption_design.dart
with open('lib/core/models/caption_design.dart', 'r') as f:
    design_code = f.read()

# Add customScale field
design_code = re.sub(
    r"final double\? customY;", 
    r"final double? customY;\n  final double? customScale;", 
    design_code
)

# Add customScale to constructor
design_code = re.sub(
    r"this\.customY,", 
    r"this.customY,\n    this.customScale,", 
    design_code
)

# Add customScale to copyWith
design_code = re.sub(
    r"double\? customY,", 
    r"double? customY,\n    double? customScale,", 
    design_code
)
design_code = re.sub(
    r"customY: customY \?\? this\.customY,", 
    r"customY: customY ?? this.customY,\n      customScale: customScale ?? this.customScale,", 
    design_code
)

# Add customScale to toMap
design_code = re.sub(
    r"'customY': customY,", 
    r"'customY': customY,\n      'customScale': customScale,", 
    design_code
)

# Add customScale to fromMap
design_code = re.sub(
    r"customY: map\['customY'\],\n", 
    r"customY: map['customY'],\n      customScale: map['customScale'],\n", 
    design_code
)

with open('lib/core/models/caption_design.dart', 'w') as f:
    f.write(design_code)
