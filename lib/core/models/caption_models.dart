class CaptionWord {
  const CaptionWord({
    required this.text,
    required this.startMs,
    required this.endMs,
    this.confidence,
  });

  final String text;
  final int startMs;
  final int endMs;
  final double? confidence;

  CaptionWord copyWith({String? text, int? startMs, int? endMs}) => CaptionWord(
        text: text ?? this.text,
        startMs: startMs ?? this.startMs,
        endMs: endMs ?? this.endMs,
        confidence: confidence,
      );
}

enum CaptionPosition { top, center, bottom }

enum CaptionAnimation { none, wordPop, karaokeFill, bounce, typewriter, slideUp, fade }

class CaptionStyle {
  const CaptionStyle({
    required this.templateId,
    required this.fontFamily,
    required this.fontSize,
    required this.fontWeight,
    required this.textColor,
    required this.activeColor,
    required this.strokeWidth,
    required this.position,
    required this.animation,
    required this.maxWordsPerLine,
  });

  final String templateId;
  final String fontFamily;
  final double fontSize;
  final int fontWeight;
  final String textColor;
  final String activeColor;
  final double strokeWidth;
  final CaptionPosition position;
  final CaptionAnimation animation;
  final int maxWordsPerLine;
}

class CaptionTemplates {
  static const names = [
    'Blink Pop',
    'Karaoke Fill',
    'Bold Box',
    'Minimal Clean',
    'Neon Glow',
    'Typewriter',
    'Bounce',
    'Podcast Clean',
  ];

  static CaptionStyle fromName(String name) {
    final animation = switch (name) {
      'Karaoke Fill' => CaptionAnimation.karaokeFill,
      'Typewriter' => CaptionAnimation.typewriter,
      'Bounce' => CaptionAnimation.bounce,
      'Minimal Clean' => CaptionAnimation.fade,
      _ => CaptionAnimation.wordPop,
    };
    return CaptionStyle(
      templateId: name,
      fontFamily: name == 'Typewriter' ? 'Courier New' : 'DM Sans',
      fontSize: name == 'Minimal Clean' ? 34 : 46,
      fontWeight: 800,
      textColor: 'FFFFFF',
      activeColor: 'FFFFFF',
      strokeWidth: name == 'Minimal Clean' ? 0 : 2,
      position: name == 'Neon Glow' ? CaptionPosition.center : CaptionPosition.bottom,
      animation: animation,
      maxWordsPerLine: 4,
    );
  }
}
