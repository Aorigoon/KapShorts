import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/providers.dart';
import '../widgets/floating_navigation.dart';
import 'projects_screen.dart'
    show showFeatureSelectionSheet, showNewProjectSheet, showTeleprompterSheet;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credits = ref.watch(creditsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: Stack(
        children: [
          // Main Scrollable Body
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. TOP CURVED HERO CARD (Threads Inspiration in B&W / Monochrome)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF141416),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(34),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.12),
                          width: 1,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar: Search Pill + Circular "+" Action Button
                        Row(
                          children: [
                            // Search Pill
                            Expanded(
                              child: Container(
                                height: 42,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.08),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search_rounded,
                                      color: Colors.white.withOpacity(0.5),
                                      size: 19,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Search clips, tools, templates...',
                                      style: GoogleFonts.manrope(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Circular "+" Button (Import / New Project)
                            GestureDetector(
                              onTap: () => showNewProjectSheet(context),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Subtitle Tag / Badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'OPUS ENGINE',
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AI Video Clipping Studio',
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Bold Main Headline (B&W Style)
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.manrope(
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                              height: 1.18,
                              color: Colors.white,
                              letterSpacing: -0.6,
                            ),
                            children: [
                              const TextSpan(text: 'Create Viral Shorts\n'),
                              TextSpan(
                                text: 'From Any Long Video',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Status & Credits Pill (Overlapping avatar style in inspiration)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Stacked monochrome AI badges
                              SizedBox(
                                width: 56,
                                height: 22,
                                child: Stack(
                                  children: [
                                    _buildAvatarBadge(Icons.auto_awesome, 0),
                                    _buildAvatarBadge(Icons.content_cut, 16),
                                    _buildAvatarBadge(Icons.subtitles, 32),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$credits Credits Left',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                ' • 100% Automated',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 2. FEED SECTION (Opus Clip & Video Studio Features)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // FEED ITEM 1: AI Smart Clipping (Opus Clip)
                        _buildFeaturePostCard(
                          context: context,
                          icon: Icons.video_collection_rounded,
                          author: 'AI Smart Clipper',
                          tag: 'Opus Cut • 1 Video ➔ 10 Shorts',
                          description:
                              'Upload any long podcast, interview, or YouTube video. Our AI detects viral hooks, reframes speakers to 9:16, and generates ready-to-publish shorts.',
                          previewWidget: _buildClipperPreview(context),
                          primaryActionText: 'Import Long Video',
                          onPrimaryAction: () => showNewProjectSheet(context),
                        ),

                        const SizedBox(height: 18),

                        // FEED ITEM 2: AI Subtitles & Dynamic Captions
                        _buildFeaturePostCard(
                          context: context,
                          icon: Icons.subtitles_rounded,
                          author: 'Smart Subtitles',
                          tag: 'Hormozi & Beast Styles',
                          description:
                              'Add high-retention animated subtitles with automatic emojis, keyword highlights, and 40+ language support with zero manual timing.',
                          previewWidget: _buildSubtitlesPreview(context),
                          primaryActionText: 'Generate Auto Captions',
                          onPrimaryAction: () => showNewProjectSheet(context),
                        ),

                        const SizedBox(height: 18),

                        // FEED ITEM 3: AI Teleprompter & Scripting
                        _buildFeaturePostCard(
                          context: context,
                          icon: Icons.camera_front_rounded,
                          author: 'AI Teleprompter',
                          tag: 'Voice-Pace Sync',
                          description:
                              'Record flawless talking-head videos while looking directly at the camera. The script auto-scrolls seamlessly with your speaking voice.',
                          previewWidget: _buildTeleprompterPreview(context),
                          primaryActionText: 'Open Teleprompter',
                          onPrimaryAction: () => showTeleprompterSheet(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Floating Navigation
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

  // Small avatar badge for top header
  static Widget _buildAvatarBadge(IconData icon, double leftOffset) {
    return Positioned(
      left: leftOffset,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: const Color(0xFF242428),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF141416), width: 2),
        ),
        child: Icon(
          icon,
          size: 11,
          color: Colors.white,
        ),
      ),
    );
  }

  // Generic Thread-Style Feature Post Card
  Widget _buildFeaturePostCard({
    required BuildContext context,
    required IconData icon,
    required String author,
    required String tag,
    required String description,
    required Widget previewWidget,
    required String primaryActionText,
    required VoidCallback onPrimaryAction,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      tag,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.more_horiz_rounded,
                color: Colors.white.withOpacity(0.4),
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Description Text
          Text(
            description,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.85),
              height: 1.45,
            ),
          ),

          const SizedBox(height: 14),

          // Nested Preview Box (Inspire mockup container)
          previewWidget,

          const SizedBox(height: 14),

          // Action Row: Primary Button + Quick Reaction/Export Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Primary CTA Button (Black & White style)
              GestureDetector(
                onTap: onPrimaryAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                        Icons.bolt_rounded,
                        color: Colors.black,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        primaryActionText,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Interaction Icons (Like, Comment, Share in B&W)
              Row(
                children: [
                  _buildSmallIconBtn(Icons.favorite_border_rounded),
                  const SizedBox(width: 14),
                  _buildSmallIconBtn(Icons.share_outlined),
                  const SizedBox(width: 14),
                  _buildSmallIconBtn(Icons.bookmark_border_rounded),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildSmallIconBtn(IconData icon) {
    return Icon(
      icon,
      color: Colors.white.withOpacity(0.5),
      size: 18,
    );
  }

  // Nested Preview 1: AI Clipper Mockup (Virality Score Badge & 9:16 reframe)
  static Widget _buildClipperPreview(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B20),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background subtle grid/lines
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 55,
                  height: 95,
                  decoration: BoxDecoration(
                    color: const Color(0xFF26262E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Center(
                    child: Icon(Icons.play_arrow_rounded, color: Colors.white54, size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 55,
                  height: 95,
                  decoration: BoxDecoration(
                    color: const Color(0xFF26262E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Center(
                    child: Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 55,
                  height: 95,
                  decoration: BoxDecoration(
                    color: const Color(0xFF26262E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Center(
                    child: Icon(Icons.play_arrow_rounded, color: Colors.white54, size: 24),
                  ),
                ),
              ],
            ),
          ),

          // Virality Badge Overlay
          Positioned(
            top: 10,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 4),
                  Text(
                    'Virality: 98/100',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Nested Preview 2: Subtitle Presets
  static Widget _buildSubtitlesPreview(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B20),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIVE PREVIEW',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: Colors.white38,
                ),
              ),
              Text(
                'Auto 40+ Languages',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  children: const [
                    TextSpan(text: 'THIS IS HOW '),
                    TextSpan(
                      text: 'VIRAL SHORTS',
                      style: TextStyle(
                        color: Colors.black,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    TextSpan(text: ' ARE MADE 🚀'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Nested Preview 3: Teleprompter Screen
  static Widget _buildTeleprompterPreview(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B20),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mic_none_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Script Auto-Scroll Ready',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Eye-contact assist • 120-160 WPM pace',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
