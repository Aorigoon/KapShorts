with open('lib/screens/editor_screen.dart', 'r') as f:
    content = f.read()

import re

# Fix the onDrag usage in VideoPreviewPlayerState
old_on_drag_usage = """          onDrag: widget.onDesignUpdate == null ? null : (delta) {
            final currentX = widget.design.customX ?? 24.0;
            final currentY = widget.design.customY ?? (widget.design.position == CaptionPosition.top ? 34.0 : widget.design.position == CaptionPosition.bottom ? 140.0 : 80.0);
            widget.onDesignUpdate!(widget.design.copyWith(customX: currentX + delta.dx, customY: currentY + delta.dy));
          },"""

new_on_drag_usage = """          onDrag: widget.onDesignUpdate == null ? null : (delta, scale) {
            final currentX = widget.design.customX ?? 24.0;
            final currentY = widget.design.customY ?? (widget.design.position == CaptionPosition.top ? 34.0 : widget.design.position == CaptionPosition.bottom ? 140.0 : 80.0);
            final currentScale = widget.design.customScale ?? 1.0;
            widget.onDesignUpdate!(widget.design.copyWith(
              customX: currentX + delta.dx, 
              customY: currentY + delta.dy,
              customScale: (currentScale + scale).clamp(0.2, 5.0),
            ));
          },"""
content = content.replace(old_on_drag_usage, new_on_drag_usage)

# Fix the GestureDetector in _CaptionOverlay to have a drag handle
old_gesture = """      child: onDrag != null 
          ? GestureDetector(
              onScaleUpdate: (details) {
                 if (details.pointerCount > 1) {
                   onDrag!(Offset.zero, details.scale);
                 } else {
                   onDrag!(details.focalPointDelta, 1.0);
                 }
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(4),
                child: Transform.scale(
                  scale: design.customScale ?? 1.0,
                  child: isCustomPosition ? child : Align(
                    alignment: design.position == CaptionPosition.center
                        ? Alignment.center
                        : design.position == CaptionPosition.top
                        ? Alignment.topCenter
                        : Alignment.bottomCenter,
                    child: child,
                  ),
                ),
              ),
            )"""

new_gesture = """      child: onDrag != null 
          ? Transform.scale(
              scale: design.customScale ?? 1.0,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onPanUpdate: (details) => onDrag!(details.delta, 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70, width: 2, style: BorderStyle.solid),
                      ),
                      child: isCustomPosition ? child : Align(
                        alignment: design.position == CaptionPosition.center
                            ? Alignment.center
                            : design.position == CaptionPosition.top
                            ? Alignment.topCenter
                            : Alignment.bottomCenter,
                        child: child,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -12,
                    bottom: -12,
                    child: GestureDetector(
                      onPanUpdate: (details) => onDrag!(Offset.zero, (details.delta.dx + details.delta.dy) * 0.005),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.open_in_full_rounded, size: 14, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            )"""

content = content.replace(old_gesture, new_gesture)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(content)
