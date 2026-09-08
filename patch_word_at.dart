    Widget wordAt(int index, {double sizeMultiplier = 1}) {
      final isSpoken = index == selectedWordIndex;
      final isEmphasized = group[index].isEmphasized;
      final isActive = isSpoken || isEmphasized;
      final wordHasOutline = isEmphasized ? design.highlightHasOutline : isSpoken ? design.activeHasOutline : true;
      
      final cleanWord = group[index].text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
      final overrideSize = design.wordSizeOverrides.isNotEmpty ? design.wordSizeOverrides[cleanWord] : null;
      final overrideBaseline = design.wordBaselineOffsets.isNotEmpty ? (design.wordBaselineOffsets[cleanWord] ?? 0.0) : 0.0;
      final effectiveSize = overrideSize ?? (isEmphasized ? (design.highlightSize ?? design.activeSize ?? design.size) : isSpoken ? (design.activeSize ?? design.size) : design.size);

      final word = CaptionWord(
        text: design.uppercase
            ? group[index].text.toUpperCase()
            : group[index].text,
        style: captionTextStyle(
          design,
          color: design.wordChip
              ? (isActive ? Colors.black : Colors.white)
              : isEmphasized
              ? (design.highlightColor ?? design.activeColor)
              : design.effect == CaptionEffect.karaoke && index <= selectedWordIndex
              ? design.activeColor
              : isSpoken
              ? design.activeColor
              : design.color,
          fontSize: effectiveSize * sizeMultiplier,
          font: isEmphasized ? (design.highlightFont ?? design.activeFont ?? design.font) : isSpoken ? (design.activeFont ?? design.font) : null,
          fontWeight: isEmphasized ? (design.highlightWeight ?? design.activeWeight ?? design.weight) : isSpoken ? (design.activeWeight ?? design.weight) : null,
          hasOutline: wordHasOutline,
        ),
        isActive: isSpoken,
        effect: design.effect,
        wordProgress:
            ((now - group[index].start) /
                    (group[index].end - group[index].start).clamp(
                      .1,
                      double.infinity,
                    ))
                .clamp(0.0, 1.0),
        textSize: effectiveSize * sizeMultiplier,
        doubleLayer: design.doubleLayer,
        hardShadow: design.hardShadow,
      );
      final chipBg = isEmphasized
          ? (design.highlightBackground != null && design.highlightBackground!.alpha > 0
              ? design.highlightBackground!
              : (design.highlightColor ?? design.activeColor))
          : isSpoken
          ? (design.activeBackground != null && design.activeBackground!.alpha > 0
              ? design.activeBackground!
              : design.activeColor)
          : design.chipColor;
      final widget = design.wordChip
          ? Container(
              padding: EdgeInsets.symmetric(
                horizontal: effectiveSize * .24,
                vertical: effectiveSize * .11,
              ),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(effectiveSize * .18),
              ),
              child: word,
            )
          : (isEmphasized && design.highlightBackground != null && design.highlightBackground!.alpha > 0)
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: effectiveSize * .18, vertical: effectiveSize * .06),
              decoration: BoxDecoration(
                color: design.highlightBackground,
                borderRadius: BorderRadius.circular(effectiveSize * .14),
              ),
              child: word,
            )
          : (isSpoken && design.activeBackground != null && design.activeBackground!.alpha > 0)
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: effectiveSize * .18, vertical: effectiveSize * .06),
              decoration: BoxDecoration(
                color: design.activeBackground,
                borderRadius: BorderRadius.circular(effectiveSize * .14),
              ),
              child: word,
            )
          : word;
      final wrapped = (isSpoken && design.activeBlink)
          ? _BlinkingWidget(child: widget)
          : widget;
      
      final positionedWord = overrideBaseline > 0 
          ? Transform.translate(offset: Offset(0, overrideBaseline * effectiveSize * 0.25), child: wrapped) 
          : wrapped;

      return GestureDetector(
        onTap: () => onWordToggled?.call(group[index].globalIndex),
        child: positionedWord,
      );
    }
