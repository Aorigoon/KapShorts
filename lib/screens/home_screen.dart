import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HERO CARD (Refined Moderate Corners, Seamless Gradient, No Partition Line)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF26272E), // Charcoal top highlight
                          Color(0xFF191A1E), // Soft dark gray
                          Color(0xFF101013), // Rich carbon black
                        ],
                        stops: [0.0, 0.55, 1.0],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20), // Moderately rounded corners (not overly rounded)
                      ),
                      // No bottom border / partition line
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Big Title
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.manrope(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              height: 1.14,
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

                        const SizedBox(height: 12),

                        // Beautiful Subtitle Line
                        Text(
                          'Turn long videos into high-converting shorts in seconds.',
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
                ],
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
