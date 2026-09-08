import sys

with open("/storage/emulated/0/SdCard/KapShorts/lib/screens/settings_screen.dart", "r") as f:
    content = f.read()

# Add imports
content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter_riverpod/flutter_riverpod.dart';\nimport '../core/providers.dart';")

# Convert to ConsumerWidget
content = content.replace("class SettingsScreen extends StatelessWidget {", "class SettingsScreen extends ConsumerWidget {")
content = content.replace("Widget build(BuildContext context) {", "Widget build(BuildContext context, WidgetRef ref) {")

# Add the toggle below Preferences
old_prefs = """              Text(
                'Preferences',
                style: GoogleFonts.manrope(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),"""

new_prefs = """              Text(
                'Preferences',
                style: GoogleFonts.manrope(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  final current = ref.read(testModeProvider);
                  ref.read(testModeProvider.notifier).state = !current;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(!current ? 'Unlimited Credits ON' : 'Unlimited Credits OFF'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: !current ? Colors.green : AppColors.surface,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 9),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: ref.watch(testModeProvider) ? Colors.green : AppColors.line,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.all_inclusive_rounded, color: ref.watch(testModeProvider) ? Colors.green : AppColors.secondary),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Unlimited Credits', style: TextStyle(fontWeight: FontWeight.w700, color: ref.watch(testModeProvider) ? Colors.green : Colors.white)),
                            const SizedBox(height: 2),
                            Text(
                              'Test mode for free subtitle generation',
                              style: TextStyle(
                                color: ref.watch(testModeProvider) ? Colors.green.withOpacity(0.8) : AppColors.secondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: ref.watch(testModeProvider),
                        onChanged: (val) {
                          ref.read(testModeProvider.notifier).state = val;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val ? 'Unlimited Credits ON' : 'Unlimited Credits OFF'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: val ? Colors.green : AppColors.surface,
                            ),
                          );
                        },
                        activeColor: Colors.green,
                        activeTrackColor: Colors.green.withOpacity(0.3),
                        inactiveThumbColor: AppColors.secondary,
                        inactiveTrackColor: AppColors.elevated,
                      ),
                    ],
                  ),
                ),
              ),"""

content = content.replace(old_prefs, new_prefs)

with open("/storage/emulated/0/SdCard/KapShorts/lib/screens/settings_screen.dart", "w") as f:
    f.write(content)
