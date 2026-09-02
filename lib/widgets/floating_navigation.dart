import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';



class FloatingNavigation extends StatelessWidget {
  const FloatingNavigation({
    required this.onCreate,
    this.currentIndex = 0,
    this.showCreateButton = true,
    super.key,
  });

  final VoidCallback onCreate;
  final int currentIndex;
  final bool showCreateButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.elevated.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  _NavImageIcon(
                    imagePath: 'assets/images/nav_home_icon.png',
                    active: currentIndex == 0,
                    onTap: currentIndex == 0 ? null : () => context.go('/'),
                  ),
                  const SizedBox(width: 8),
                  _NavImageIcon(
                    imagePath: 'assets/images/nav_project_icon.png',
                    active: currentIndex == 1,
                    onTap: currentIndex == 1 ? null : () => context.go('/projects'),
                  ),
                  const SizedBox(width: 8),
                  _NavImageIcon(
                    imagePath: 'assets/images/nav_settings_icon.png',
                    active: currentIndex == 2,
                    onTap: currentIndex == 2 ? null : () => context.go('/settings'),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showCreateButton) ...[
          const SizedBox(width: 12),
          SizedBox(
            height: 58,
            width: 58,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onCreate,
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.black,
                  size: 31,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _NavImageIcon extends StatelessWidget {
  const _NavImageIcon({required this.imagePath, required this.active, this.onTap});
  final String imagePath;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 42,
        width: 42,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Subtle white glow BEHIND the icon when active (not too strong)
            if (active)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.55),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            // Original 3D icon — NO color filter at all
            Transform.scale(
              scale: 1.4,
              child: Image.asset(
                imagePath,
                // Inactive icons slightly dimmed so active one stands out
                opacity: active
                    ? const AlwaysStoppedAnimation(1.0)
                    : const AlwaysStoppedAnimation(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
