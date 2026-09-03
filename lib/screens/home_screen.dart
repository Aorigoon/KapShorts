import 'package:flutter/material.dart';
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
          const SafeArea(
            child: SizedBox.shrink(),
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
