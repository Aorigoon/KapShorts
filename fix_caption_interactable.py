import re

with open('lib/screens/editor_screen.dart', 'r') as f:
    text = f.read()

# Define the new _CaptionInteractable widget
interactable_widget = """class _CaptionInteractable extends StatefulWidget {
  final Widget child;
  final CaptionDesign design;
  final void Function(Offset delta, double scale) onUpdate;
  final bool isCustomPosition;

  const _CaptionInteractable({
    required this.child,
    required this.design,
    required this.onUpdate,
    required this.isCustomPosition,
    super.key,
  });

  @override
  State<_CaptionInteractable> createState() => _CaptionInteractableState();
}

class _CaptionInteractableState extends State<_CaptionInteractable> {
  double _baseScale = 1.0;

  Widget _buildCornerDot(int x, int y) {
    return Positioned(
      left: x < 0 ? -6 : null,
      right: x > 0 ? -6 : null,
      top: y < 0 ? -6 : null,
      bottom: y > 0 ? -6 : null,
      child: GestureDetector(
        onPanUpdate: (details) {
          double dx = details.delta.dx * x;
          double dy = details.delta.dy * y;
          double scaleChange = (dx + dy) * 0.005;
          double currentScale = widget.design.customScale ?? 1.0;
          widget.onUpdate(Offset.zero, (currentScale + scaleChange).clamp(0.2, 5.0));
        },
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blueAccent, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 2)],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: widget.design.customScale ?? 1.0,
      child: Align(
        alignment: widget.isCustomPosition ? Alignment.topLeft : (
          widget.design.position == CaptionPosition.center
            ? Alignment.center
            : widget.design.position == CaptionPosition.top
            ? Alignment.topCenter
            : Alignment.bottomCenter
        ),
        child: GestureDetector(
          onScaleStart: (_) {
            _baseScale = widget.design.customScale ?? 1.0;
          },
          onScaleUpdate: (details) {
            if (details.pointerCount >= 2) {
              widget.onUpdate(Offset.zero, (_baseScale * details.scale).clamp(0.2, 5.0));
            } else {
              widget.onUpdate(details.focalPointDelta, widget.design.customScale ?? 1.0);
            }
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5, style: BorderStyle.dashed),
                ),
                child: widget.child,
              ),
              _buildCornerDot(-1, -1),
              _buildCornerDot(1, -1),
              _buildCornerDot(-1, 1),
              _buildCornerDot(1, 1),
            ],
          ),
        ),
      ),
    );
  }
}
"""

# Insert _CaptionInteractable class above _CaptionOverlay
text = re.sub(r"class _CaptionOverlay extends StatelessWidget \{", interactable_widget + "\nclass _CaptionOverlay extends StatelessWidget {", text)


# Update the onDrag usage inside _CaptionOverlay
old_ondrag = """      child: onDrag != null 
          ? Transform.scale(
              scale: design.customScale ?? 1.0,
              child: Align(
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
              ),
            )"""

new_ondrag = """      child: onDrag != null 
          ? _CaptionInteractable(
              design: design,
              onUpdate: onDrag!,
              isCustomPosition: isCustomPosition,
              child: child,
            )"""

text = text.replace(old_ondrag, new_ondrag)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(text)
