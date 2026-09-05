import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/floating_navigation.dart';
import 'projects_screen.dart' show showFeatureSelectionSheet;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: Stack(
        children: [
          // Scrollable Body
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER SECTION (No Background Card)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Main Title / Caption Header
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.manrope(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                                color: Colors.white,
                                letterSpacing: -0.8,
                              ),
                              children: [
                                const TextSpan(text: 'Create\n'),
                                TextSpan(
                                  text: 'Viral Clips',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.95),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Right: Get PRO & Credits Chips
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Get PRO Chip
                            Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1F25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.12),
                                ),
                              ),
                              child: Text(
                                'Get PRO',
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Credit Chip (16 Credits)
                            Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1F25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.12),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.bolt_rounded,
                                    color: Color(0xFFFFC107),
                                    size: 17,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '16',
                                    style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Elegant Subtitle / Tagline Line
                    Text(
                      'Turn long videos into high-converting AI captions & viral shorts in seconds.',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.55),
                        height: 1.4,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Floating Navigation
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
              child: FloatingNavigation(
                currentIndex: 0,
                onCreate: () => showFeatureSelectionSheet(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

