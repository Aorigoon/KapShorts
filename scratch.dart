        } else if (tool == EditorTool.canvas) {
          content = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.touch_app_rounded, color: Colors.white70, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Drag captions directly on the video to move them. Use the sliders below for fine-tuning.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text('Horizontal (X)', style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('${design.customX?.round() ?? 0}', style: const TextStyle(color: AppColors.secondary)),
                ],
              ),
              Slider(
                value: design.customX ?? 0,
                min: -300,
                max: 300,
                activeColor: Colors.white,
                inactiveColor: AppColors.line,
                onChanged: (val) => updateDesign(design.copyWith(customX: val)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Vertical (Y)', style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('${design.customY?.round() ?? 0}', style: const TextStyle(color: AppColors.secondary)),
                ],
              ),
              Slider(
                value: design.customY ?? 0,
                min: -500,
                max: 500,
                activeColor: Colors.white,
                inactiveColor: AppColors.line,
                onChanged: (val) => updateDesign(design.copyWith(customY: val)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Scale', style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('${(design.customScale ?? 1.0).toStringAsFixed(2)}x', style: const TextStyle(color: AppColors.secondary)),
                ],
              ),
              Slider(
                value: design.customScale ?? 1.0,
                min: 0.2,
                max: 3.0,
                activeColor: Colors.white,
                inactiveColor: AppColors.line,
                onChanged: (val) => updateDesign(design.copyWith(customScale: val)),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () => updateDesign(design.copyWith(customX: null, customY: null, customScale: 1.0)),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reset positions'),
                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                ),
              ),
            ],
          );
        }
