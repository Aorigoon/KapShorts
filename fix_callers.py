import re
with open('lib/screens/editor_screen.dart', 'r') as f:
    text = f.read()

# Fix CustomizeSheet onDrag
old_cust = """                            onDrag: (delta, scale) {
                              double currentX = design.customX ?? 24.0;
                              double currentY = design.customY ?? (design.position == CaptionPosition.top ? 34.0 : design.position == CaptionPosition.bottom ? 140.0 : 80.0);
                              double currentScale = design.customScale ?? 1.0;
                              ref.read(captionDesignProvider.notifier).state = design.copyWith(
                                customX: currentX + delta.dx, 
                                customY: currentY + delta.dy,
                                customScale: (currentScale + scale).clamp(0.2, 5.0),
                              );
                            },"""

new_cust = """                            onDrag: (delta, scale) {
                              double currentX = design.customX ?? 24.0;
                              double currentY = design.customY ?? (design.position == CaptionPosition.top ? 34.0 : design.position == CaptionPosition.bottom ? 140.0 : 80.0);
                              ref.read(captionDesignProvider.notifier).state = design.copyWith(
                                customX: currentX + delta.dx, 
                                customY: currentY + delta.dy,
                                customScale: scale,
                              );
                            },"""

text = text.replace(old_cust, new_cust)

# Fix VideoPreviewPlayerState onDrag
old_vp = """          onDrag: widget.onDesignUpdate == null ? null : (delta, scale) {
            final currentX = widget.design.customX ?? 24.0;
            final currentY = widget.design.customY ?? (widget.design.position == CaptionPosition.top ? 34.0 : widget.design.position == CaptionPosition.bottom ? 140.0 : 80.0);
            final currentScale = widget.design.customScale ?? 1.0;
            widget.onDesignUpdate!(widget.design.copyWith(
              customX: currentX + delta.dx, 
              customY: currentY + delta.dy,
              customScale: (currentScale + scale).clamp(0.2, 5.0),
            ));
          },"""

new_vp = """          onDrag: widget.onDesignUpdate == null ? null : (delta, scale) {
            final currentX = widget.design.customX ?? 24.0;
            final currentY = widget.design.customY ?? (widget.design.position == CaptionPosition.top ? 34.0 : widget.design.position == CaptionPosition.bottom ? 140.0 : 80.0);
            widget.onDesignUpdate!(widget.design.copyWith(
              customX: currentX + delta.dx, 
              customY: currentY + delta.dy,
              customScale: scale,
            ));
          },"""

text = text.replace(old_vp, new_vp)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(text)
