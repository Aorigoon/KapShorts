import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/providers.dart';
import '../widgets/floating_navigation.dart';
import 'projects_screen.dart' show showFeatureSelectionSheet, showNewProjectSheet;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credits = ref.watch(creditsProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          // Main Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Bar: No menu icon, KapShorts title on left, compact chips on right
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: KapShorts App Title (No hamburger / 3 lines icon)
                        Text(
                          'KapShorts',
                          style: GoogleFonts.manrope(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),

                        // Right: Compact Refined Chips (Credits & Pro)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Credits Chip
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.12),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.bolt_rounded,
                                    color: Color(0xFFFBBF24),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$credits',
                                    style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Get Pro Chip
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.workspace_premium_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Pro',
                                    style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
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

                  const SizedBox(height: 14),

                  // 2. Headline
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.manrope(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        children: const [
                          TextSpan(text: 'Create without\n'),
                          TextSpan(
                            text: 'limits.',
                            style: TextStyle(
                              color: Color(0xFFA78BFA),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 3. Single Main Action Card for Gallery Import ("Ek hi call use karo")
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () => showNewProjectSheet(context),
                      child: Container(
                        width: double.infinity,
                        height: 125,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.22),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 0, height: 6), // Zero side gap, minimal top gap
                            Text(
                              'New Project',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Import from gallery',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. Tools Section (Moved up, zero gap between icon and text)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Tools',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.95,
                      children: [
                        _ToolButton(
                          icon: Icons.content_cut_rounded,
                          label: 'Trim',
                          onTap: () => showNewProjectSheet(context),
                        ),
                        _ToolButton(
                          icon: Icons.call_split_rounded,
                          label: 'Split',
                          onTap: () => showNewProjectSheet(context),
                        ),
                        _ToolButton(
                          icon: Icons.speed_rounded,
                          label: 'Speed',
                          onTap: () => showNewProjectSheet(context),
                        ),
                        _ToolButton(
                          icon: Icons.tune_rounded,
                          label: 'Filters',
                          onTap: () => showNewProjectSheet(context),
                        ),
                        _ToolButton(
                          icon: Icons.subtitles_rounded,
                          label: 'Text',
                          onTap: () => showNewProjectSheet(context),
                        ),
                        _ToolButton(
                          icon: Icons.music_note_rounded,
                          label: 'Music',
                          onTap: () => showNewProjectSheet(context),
                        ),
                        _ToolButton(
                          icon: Icons.auto_awesome_rounded,
                          label: 'Effects',
                          onTap: () => showNewProjectSheet(context),
                        ),
                        _ToolButton(
                          icon: Icons.mic_rounded,
                          label: 'Voiceover',
                          onTap: () => showNewProjectSheet(context),
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

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF14141B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 22,
            ),
            const SizedBox(height: 3), // Zero / tight gap between icon and text
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
