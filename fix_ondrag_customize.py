with open('lib/screens/editor_screen.dart', 'r') as f:
    text = f.read()

old_drag = """                            onDrag: (delta) {
                              double currentX = design.customX ?? 24.0;
                              double currentY = design.customY ?? (design.position == CaptionPosition.top ? 34.0 : design.position == CaptionPosition.bottom ? 140.0 : 80.0);
                              ref.read(captionDesignProvider.notifier).state = design.copyWith(customX: currentX + delta.dx, customY: currentY + delta.dy);
                            },"""

new_drag = """                            onDrag: (delta, scale) {
                              double currentX = design.customX ?? 24.0;
                              double currentY = design.customY ?? (design.position == CaptionPosition.top ? 34.0 : design.position == CaptionPosition.bottom ? 140.0 : 80.0);
                              double currentScale = design.customScale ?? 1.0;
                              ref.read(captionDesignProvider.notifier).state = design.copyWith(
                                customX: currentX + delta.dx, 
                                customY: currentY + delta.dy,
                                customScale: (currentScale + scale).clamp(0.2, 5.0),
                              );
                            },"""

text = text.replace(old_drag, new_drag)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(text)
