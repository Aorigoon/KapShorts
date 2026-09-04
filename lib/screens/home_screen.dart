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
                  // 1. TOP HERO CURVED CARD (Exact Black, White & Gray Mixture from Inspiration)
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
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar: Search Pill + Circular "+" Action Button
                        Row(
                          children: [
                            // Search Pill (Frosted Gray & White)
                            Expanded(
                              child: Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.14),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search_rounded,
                                      color: Colors.white.withOpacity(0.75),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Search',
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.65),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Circular "+" Button (Clean White/Glass Button)
                            GestureDetector(
                              onTap: () => showNewProjectSheet(context),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.14),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.06),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Subtitle / Category Tag (like "Beta Community" in inspiration)
                        Text(
                          'AI Video Clipping & Studio',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.65),
                            letterSpacing: 0.2,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Main Big Tagline (Where "Design Threads" was written)
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.manrope(
                              fontSize: 35,
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

                        const SizedBox(height: 24),

                        // Bottom Status Pill (Overlapping Avatars + Stats in Inspiration)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.16),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Overlapping Avatar Circles (Black, Gray, White)
                                  SizedBox(
                                    width: 60,
                                    height: 22,
                                    child: Stack(
                                      children: [
                                        _buildAvatarCircle(
                                          offset: 0,
                                          color: const Color(0xFF4A4B54),
                                          icon: Icons.bolt_rounded,
                                        ),
                                        _buildAvatarCircle(
                                          offset: 16,
                                          color: const Color(0xFF6B6D7A),
                                          icon: Icons.auto_awesome,
                                        ),
                                        _buildAvatarCircle(
                                          offset: 32,
                                          color: const Color(0xFFFFFFFF),
                                          icon: Icons.content_cut_rounded,
                                          iconColor: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '16.8k clips • 98% viral score',
                                    style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withOpacity(0.9),
                                      letterSpacing: 0.1,
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

                  const SizedBox(height: 24),

                  // 2. CONTENT FEED (Clean Black & White / Gray video studio cards)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Card 1: AI Opus Clipper
                        _buildStudioCard(
                          context: context,
                          title: 'Opus AI Clipper',
                          timeAgo: '2h ago',
                          description:
                              'Automatically extract viral hooks and key moments from long YouTube videos or gallery clips.',
                          viralityTag: '🔥 98/100 Virality Score',
                          badgeColor: const Color(0xFF2A2B32),
                          buttonText: 'Import Video',
                          onTap: () => showNewProjectSheet(context),
                        ),

                        const SizedBox(height: 18),

                        // Card 2: AI Subtitles & Dynamic Captions
                        _buildStudioCard(
                          context: context,
                          title: 'Smart Subtitles',
                          timeAgo: '4h ago',
                          description:
                              'Generate word-by-word animated subtitles in Hormozi & Beast style with auto-emojis.',
                          viralityTag: '⚡ 40+ Languages • Whisper AI',
                          badgeColor: const Color(0xFF222328),
                          buttonText: 'Add Captions',
                          onTap: () => showNewProjectSheet(context),
                        ),

                        const SizedBox(height: 18),

                        // Card 3: AI Teleprompter
                        _buildStudioCard(
                          context: context,
                          title: 'AI Teleprompter',
                          timeAgo: 'Just now',
                          description:
                              'Record talking-head videos with seamless voice-synced auto-scroll and direct camera eye contact.',
                          viralityTag: '🎙️ Voice-Paced Sync',
                          badgeColor: const Color(0xFF1E1F24),
                          buttonText: 'Open Prompter',
                          onTap: () => showTeleprompterSheet(context),
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

  // Overlapping avatar circle helper
  static Widget _buildAvatarCircle({
    required double offset,
    required Color color,
    required IconData icon,
    Color iconColor = Colors.white,
  }) {
    return Positioned(
      left: offset,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF1E1F25),
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 10,
            color: iconColor,
          ),
        ),
      ),
    );
  }

  // Monochrome Studio Feed Card
  static Widget _buildStudioCard({
    required BuildContext context,
    required String title,
    required String timeAgo,
    required String description,
    required String viralityTag,
    required Color badgeColor,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF131417),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.09),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    timeAgo,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.more_horiz,
                color: Colors.white38,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            description,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.8),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 14),

          // Virality Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Text(
              viralityTag,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bottom Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    buttonText,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    color: Colors.white38,
                    size: 18,
                  ),
                  const SizedBox(width: 14),
                  Icon(
                    Icons.share_outlined,
                    color: Colors.white38,
                    size: 18,
                  ),
                  const SizedBox(width: 14),
                  Icon(
                    Icons.bookmark_border_rounded,
                    color: Colors.white38,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
