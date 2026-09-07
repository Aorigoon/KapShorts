with open('lib/screens/editor_screen.dart', 'r') as f:
    content = f.read()

import re

# Update _CaptionOverlay signature
content = content.replace("final void Function(Offset delta)? onDrag;", "final void Function(Offset delta, double scale)? onDrag;")

# Update _CaptionOverlay GestureDetector
old_gesture = """      child: onDrag != null 
          ? GestureDetector(
              onPanUpdate: (details) => onDrag!(details.delta),
              child: isCustomPosition ? child : Align(
                alignment: design.position == CaptionPosition.center
                    ? Alignment.center
                    : design.position == CaptionPosition.top
                    ? Alignment.topCenter
                    : Alignment.bottomCenter,
                child: child,
              ),
            )"""

new_gesture = """      child: onDrag != null 
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

content = content.replace(old_gesture, new_gesture)

# Also apply transform.scale when not dragging
old_no_drag = """          : (isCustomPosition ? child : Align(
              alignment: design.position == CaptionPosition.center
                  ? Alignment.center
                  : design.position == CaptionPosition.top
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              child: child,
            )),"""

new_no_drag = """          : Transform.scale(
              scale: design.customScale ?? 1.0,
              child: (isCustomPosition ? child : Align(
                alignment: design.position == CaptionPosition.center
                    ? Alignment.center
                    : design.position == CaptionPosition.top
                    ? Alignment.topCenter
                    : Alignment.bottomCenter,
                child: child,
              )),
            ),"""

content = content.replace(old_no_drag, new_no_drag)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(content)
