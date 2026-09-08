        } else if (tool == EditorTool.canvas) {
          final rawSegments = ref.read(transcriptionProvider)?['segments'] ?? ref.read(projectsProvider).selected?.transcription?['segments'];
          final uniqueWords = <String>{};
          if (rawSegments is List) {
            for (final seg in rawSegments) {
              if (seg is Map && seg['words'] is List) {
                for (final w in seg['words']) {
                  if (w is Map && w['text'] != null) {
                    final clean = w['text'].toString().trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
                    if (clean.isNotEmpty) uniqueWords.add(clean);
                  }
                }
              }
            }
          }
          final wordsList = uniqueWords.toList();

          content = StatefulBuilder(
            builder: (ctx, setLocal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tap any word from your video to customize its size and baseline.', style: TextStyle(color: AppColors.secondary, fontSize: 13)),
                  const SizedBox(height: 12),
                  if (wordsList.isNotEmpty)
                    Container(
                      height: 110,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.elevated,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: wordsList.map((word) {
                            final isSelected = design.wordSizeOverrides.containsKey(word);
                            return GestureDetector(
                              onTap: () {
                                final newSizes = Map<String, double>.from(design.wordSizeOverrides);
                                final newOffsets = Map<String, double>.from(design.wordBaselineOffsets);
                                if (isSelected) {
                                  newSizes.remove(word);
                                  newOffsets.remove(word);
                                } else {
                                  newSizes[word] = design.size;
                                  newOffsets[word] = 0;
                                }
                                updateDesign(design.copyWith(wordSizeOverrides: newSizes, wordBaselineOffsets: newOffsets));
                                setLocal(() {});
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : AppColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isSelected ? Colors.white : AppColors.line),
                                ),
                                child: Text(
                                  word,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  if (design.wordSizeOverrides.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text('Word Overrides', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.secondary)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 220,
                      child: ListView(
                        children: [
                          for (final word in design.wordSizeOverrides.keys.toList()) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.fromLTRB(14, 10, 10, 12),
                              decoration: BoxDecoration(
                                color: AppColors.elevated,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '"$word"',
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          final offsets = Map<String, double>.from(design.wordBaselineOffsets);
                                          offsets[word] = (offsets[word] ?? 0) == 0 ? 8.0 : 0.0;
                                          updateDesign(design.copyWith(wordBaselineOffsets: offsets));
                                          setLocal(() {});
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: (design.wordBaselineOffsets[word] ?? 0) > 0
                                                ? Colors.white
                                                : AppColors.surface,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: (design.wordBaselineOffsets[word] ?? 0) > 0
                                                  ? Colors.white
                                                  : AppColors.line,
                                            ),
                                          ),
                                          child: Text(
                                            'Sub',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: (design.wordBaselineOffsets[word] ?? 0) > 0
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          final newSizes = Map<String, double>.from(design.wordSizeOverrides)..remove(word);
                                          final newOffsets = Map<String, double>.from(design.wordBaselineOffsets)..remove(word);
                                          updateDesign(design.copyWith(wordSizeOverrides: newSizes, wordBaselineOffsets: newOffsets));
                                          setLocal(() {});
                                        },
                                        child: const Icon(Icons.close_rounded, size: 18, color: AppColors.secondary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        '${(design.wordSizeOverrides[word] ?? design.size).round()} px',
                                        style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          value: design.wordSizeOverrides[word] ?? design.size,
                                          min: 12,
                                          max: 80,
                                          divisions: 34,
                                          activeColor: Colors.white,
                                          inactiveColor: AppColors.line,
                                          onChanged: (val) {
                                            final newSizes = Map<String, double>.from(design.wordSizeOverrides);
                                            newSizes[word] = val;
                                            updateDesign(design.copyWith(wordSizeOverrides: newSizes));
                                            setLocal(() {});
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        }
