import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ad_service.dart';
import 'mining_tab.dart';
import '../tasks/tasks_screen.dart';
import '../games/mini_games_screen.dart';
import '../team/team_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../profile/enhanced_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MiningTab(),
    const TasksScreen(),
    const MiniGamesScreen(),
    const LeaderboardScreen(),
    const EnhancedProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final adService = context.watch<AdService>();
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner Ad
          if (adService.isBannerAdLoaded && adService.bannerAd != null)
            Container(
              height: 50,
              color: const Color(0xFF0A0E27),
              child: AdWidget(ad: adService.bannerAd!),
            ),
          
          // Navigation Bar
          Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A).withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.hub_rounded, 'Mine'),
                _buildNavItem(1, Icons.task_alt, 'Tasks'),
                _buildNavItem(2, Icons.sports_esports, 'Games'),
                _buildNavItem(3, Icons.leaderboard, 'Ranks'),
                _buildNavItem(4, Icons.person, 'Profile'),
              ],
            ),
          ),
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    const Color(0xFF06B6D4).withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF06B6D4)
                  : Colors.white.withValues(alpha: 0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF06B6D4)
                    : Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
