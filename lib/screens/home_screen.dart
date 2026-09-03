import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/providers.dart';
import '../widgets/floating_navigation.dart';
import 'projects_screen.dart' show showFeatureSelectionSheet;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credits = ref.watch(creditsProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header: Logo (flush to left edge) + Smaller Chips (Credits + Get Pro)
                  Padding(
                    padding: const EdgeInsets.only(left: 0, right: 16, top: 4, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // App Logo Icon (Shifted flush to left edge, larger size)
                        Transform.translate(
                          offset: const Offset(-6, 0),
                          child: Image.asset(
                            'assets/icon_foreground.png',
                            width: 88,
                            height: 88,
                          ),
                        ),

                        // Right Side: Smaller Chips (Credits Chip + Get Pro Button)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Credits Chip (smaller size, dynamic count)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.18),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.bolt,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '$credits Credits',
                                    style: GoogleFonts.manrope(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 6),

                            // Get Pro Button (smaller size)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.workspace_premium,
                                    color: Colors.black,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Get Pro',
                                    style: GoogleFonts.manrope(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Expanded & Beautiful Tagline / Hero Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge / Accent line
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 13,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'AI Powered Video Studio',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Expanded Main Title
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.manrope(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                            children: const [
                              TextSpan(text: 'Transform Ideas\nInto '),
                              TextSpan(
                                text: 'Stunning AI Videos',
                                style: TextStyle(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white38,
                                  decorationThickness: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Expanded Subtitle Tagline
                        Text(
                          'Create professional shorts, auto-captions, and high-converting AI content in seconds.',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white60,
                            height: 1.45,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom floating navigation
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
