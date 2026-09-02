import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';

class FloatingNavigation extends StatelessWidget {
  const FloatingNavigation({
    required this.onCreate,
    this.currentIndex = 0,
    super.key,
  });

  final VoidCallback onCreate;
  final int currentIndex;

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
                  _NavIcon(
                    icon: Icons.person_outline_rounded,
                    active: currentIndex == 2,
                    onTap: currentIndex == 2 ? null : () => context.go('/settings'),
                  ),
                ],
              ),
            ),
          ),
        ),
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
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.active, this.onTap});
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 23,
          color: active ? Colors.black : Colors.white,
        ),
      ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Transform.scale(
          scale: 1.4, // The images have large transparent padding
          child: Image.asset(
            imagePath,
            // NO color filter! We want the original 3D icon to show fully.
          ),
        ),
      ),
    );
  }
}
