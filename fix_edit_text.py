import re

with open('lib/screens/editor_screen.dart', 'r') as f:
    text = f.read()

old_box = """                          _CaptionOverlay(
                            transcription: transcription,
                            position: controller.value.position,
                            design: design,
                            onDrag: (delta, scale) {
                              double currentX = design.customX ?? 24.0;
                              double currentY = design.customY ?? (design.position == CaptionPosition.top ? 34.0 : design.position == CaptionPosition.bottom ? 140.0 : 80.0);
                              ref.read(captionDesignProvider.notifier).state = design.copyWith(
                                customX: currentX + delta.dx, 
                                customY: currentY + delta.dy,
                                customScale: scale,
                              );
                            },
                          ),"""

new_box = """                          _CaptionOverlay(
                            transcription: transcription,
                            position: controller.value.position,
                            design: design.copyWith(
                              position: CaptionPosition.center,
                              customX: null,
                              customY: null,
                              customScale: 1.0,
                            ),
                            // Position is fixed in the center for the Edit Text preview box
                          ),"""

text = text.replace(old_box, new_box)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(text)
