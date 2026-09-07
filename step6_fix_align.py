with open('lib/screens/editor_screen.dart', 'r') as f:
    content = f.read()

old_stack = """              child: Stack(
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
              ),"""

new_stack = """              child: Align(
                alignment: isCustomPosition ? Alignment.topLeft : (
                  design.position == CaptionPosition.center
                    ? Alignment.center
                    : design.position == CaptionPosition.top
                    ? Alignment.topCenter
                    : Alignment.bottomCenter
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onPanUpdate: (details) => onDrag!(details.delta, 0.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white70, width: 2, style: BorderStyle.solid),
                        ),
                        child: child,
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
              ),"""

content = content.replace(old_stack, new_stack)

# Also fix the no-drag branch to have Align on the outside
old_no_drag = """          : Transform.scale(
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

new_no_drag = """          : Transform.scale(
              scale: design.customScale ?? 1.0,
              child: Align(
                alignment: isCustomPosition ? Alignment.topLeft : (
                  design.position == CaptionPosition.center
                      ? Alignment.center
                      : design.position == CaptionPosition.top
                      ? Alignment.topCenter
                      : Alignment.bottomCenter
                ),
                child: child,
              ),
            ),"""

content = content.replace(old_no_drag, new_no_drag)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(content)
