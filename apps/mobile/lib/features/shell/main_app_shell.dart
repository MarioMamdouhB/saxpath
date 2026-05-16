import 'package:flutter/material.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/academy/video_library_screen.dart';
import 'package:saxpath_mobile/features/academy/learn_path_screen.dart';
import 'package:saxpath_mobile/features/home/home_screen.dart';
import 'package:saxpath_mobile/features/home/practice_room_screen.dart';
import 'package:saxpath_mobile/features/community/leaderboard_screen.dart';
import 'package:saxpath_mobile/features/profile/player_profile_screen.dart';
import 'package:saxpath_mobile/features/progress/progress_screen.dart';

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key, required this.apiClient});

  final SaxPathApiClient apiClient;

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(apiClient: widget.apiClient),
      LearnPathScreen(apiClient: widget.apiClient),
      const VideoLibraryScreen(),
      const LeaderboardScreen(),
      const PlayerProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.deepTeal,
        unselectedItemColor: AppColors.muted,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.today_rounded),
            label: 'اليوم',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_rounded),
            label: 'تعلم',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_rounded),
            label: 'المكتبة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_rounded),
            label: 'المتصدرين',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'الملف',
          ),
        ],
      ),
    );
  }
}
