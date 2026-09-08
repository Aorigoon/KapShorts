import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';
import '../core/utils.dart';
import '../widgets/floating_navigation.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.elevated,
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Creator workspace',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Your caption projects stay on this device.',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Preferences',
                style: GoogleFonts.manrope(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  final current = ref.read(testModeProvider);
                  ref.read(testModeProvider.notifier).state = !current;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(!current ? 'Unlimited Credits ON' : 'Unlimited Credits OFF'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: !current ? Colors.green : AppColors.surface,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 9),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: ref.watch(testModeProvider) ? Colors.green : AppColors.line,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.all_inclusive_rounded, color: ref.watch(testModeProvider) ? Colors.green : AppColors.secondary),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Unlimited Credits', style: TextStyle(fontWeight: FontWeight.w700, color: ref.watch(testModeProvider) ? Colors.green : Colors.white)),
                            const SizedBox(height: 2),
                            Text(
                              'Test mode for free subtitle generation',
                              style: TextStyle(
                                color: ref.watch(testModeProvider) ? Colors.green.withOpacity(0.8) : AppColors.secondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: ref.watch(testModeProvider),
                        onChanged: (val) {
                          ref.read(testModeProvider.notifier).state = val;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val ? 'Unlimited Credits ON' : 'Unlimited Credits OFF'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: val ? Colors.green : AppColors.surface,
                            ),
                          );
                        },
                        activeColor: Colors.green,
                        activeTrackColor: Colors.green.withOpacity(0.3),
                        inactiveThumbColor: AppColors.secondary,
                        inactiveTrackColor: AppColors.elevated,
                      ),
                    ],
                  ),
                ),
              ),
              const _SettingsItem(
                icon: Icons.dark_mode_outlined,
                title: 'Dark appearance',
                detail: 'Always on',
              ),
              const _SettingsItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Your privacy',
                detail: 'Projects are stored on this device',
              ),
              const _SettingsItem(
                icon: Icons.info_outline_rounded,
                title: 'About',
                detail: 'Version 1.0.0',
              ),
            ],
          ),
          // Bottom navigation — no + button on profile page
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
              child: FloatingNavigation(
                currentIndex: 1,
                showCreateButton: false,
                onCreate: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class ConnectionPill extends StatelessWidget {
  const ConnectionPill({required this.connected, super.key});
  final bool connected;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: connected ? const Color(0xFF16321D) : AppColors.elevated,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      connected ? 'Saved' : 'Not connected',
      style: TextStyle(
        color: connected ? AppColors.success : AppColors.secondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.detail,
  });
  final IconData icon;
  final String title;
  final String detail;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 9),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppColors.line),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.secondary),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                detail,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: AppColors.secondary),
      ],
    ),
  );
}
