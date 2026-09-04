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
                  // TOP HERO CURVED CARD (Black, White & Gray Mixture Header Card)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2C2D36), // Grayish-charcoal highlight
                          Color(0xFF1E1F25), // Medium deep gray
                          Color(0xFF121316), // Dark carbon black
                        ],
                        stops: [0.0, 0.55, 1.0],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(38),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.15),
                          width: 1.2,
                        ),
                        left: BorderSide(
                          color: Colors.white.withOpacity(0.08),
                          width: 1,
                        ),
                        right: BorderSide(
                          color: Colors.white.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.7),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Big Tagline
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.manrope(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              height: 1.12,
                              color: Colors.white,
                              letterSpacing: -1.0,
                            ),
                            children: [
                              const TextSpan(text: 'Create\n'),
                              TextSpan(
                                text: 'Viral Clips',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.92),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
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
