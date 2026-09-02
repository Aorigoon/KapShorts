import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../widgets/floating_navigation.dart';
import 'projects_screen.dart' show showFeatureSelectionSheet;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Logo icon + "apShorts" text (K is already shown in logo)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icon_foreground.png',
                        width: 38,
                        height: 38,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'apShorts',
                        style: GoogleFonts.manrope(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
