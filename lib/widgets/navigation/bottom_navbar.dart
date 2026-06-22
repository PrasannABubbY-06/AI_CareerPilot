import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../common/glass_container.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: GlassContainer(
          padding: EdgeInsets.zero,
          blur: 20,
          opacity: 0.06,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTap,
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.white38,
              selectedFontSize: 12,
              unselectedFontSize: 11,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.grid_view_rounded),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.grid_view_rounded, shadows: [
                      Shadow(
                        color: AppColors.primary,
                        blurRadius: 10,
                      )
                    ]),
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.analytics_rounded),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.analytics_rounded, shadows: [
                      Shadow(
                        color: AppColors.primary,
                        blurRadius: 10,
                      )
                    ]),
                  ),
                  label: "Skills",
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.description_rounded),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.description_rounded, shadows: [
                      Shadow(
                        color: AppColors.primary,
                        blurRadius: 10,
                      )
                    ]),
                  ),
                  label: "Resume",
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.mic_none_rounded),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.mic_rounded, shadows: [
                      Shadow(
                        color: AppColors.primary,
                        blurRadius: 10,
                      )
                    ]),
                  ),
                  label: "Interview",
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.work_outline_rounded),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.work_rounded, shadows: [
                      Shadow(
                        color: AppColors.primary,
                        blurRadius: 10,
                      )
                    ]),
                  ),
                  label: "JD Match",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}