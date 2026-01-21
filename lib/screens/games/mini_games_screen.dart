import 'package:flutter/material.dart';
import 'dart:math' as math;

class MiniGamesScreen extends StatelessWidget {
  const MiniGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Games'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    const Color(0xFF06B6D4).withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
                      ),
                    ),
                    child: const Icon(
                      Icons.sports_esports,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Play & Earn',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Compete and win Voidium tokens!',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Games grid
            _buildGameCard(
              context,
              'Tap Master',
              'Tap as fast as you can!',
              Icons.touch_app,
              const Color(0xFF8B5CF6),
              100.0,
              () => _showComingSoon(context, 'Tap Master'),
            ),
            const SizedBox(height: 12),
            _buildGameCard(
              context,
              'Memory Match',
              'Match the crypto cards',
              Icons.casino,
              const Color(0xFF06B6D4),
              150.0,
              () => _showComingSoon(context, 'Memory Match'),
            ),
            const SizedBox(height: 12),
            _buildGameCard(
              context,
              'Number Rush',
              'Quick math challenges',
              Icons.calculate,
              const Color(0xFFEC4899),
              120.0,
              () => _showComingSoon(context, 'Number Rush'),
            ),
            const SizedBox(height: 12),
            _buildGameCard(
              context,
              'Lucky Spin',
              'Daily fortune wheel',
              Icons.album,
              const Color(0xFFFFD700),
              200.0,
              () => _showComingSoon(context, 'Lucky Spin'),
            ),
            const SizedBox(height: 12),
            _buildGameCard(
              context,
              'Puzzle Slider',
              'Solve the puzzle',
              Icons.extension,
              const Color(0xFF10B981),
              175.0,
              () => _showComingSoon(context, 'Puzzle Slider'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    double reward,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1F3A).withValues(alpha: 0.8),
              const Color(0xFF1A1F3A).withValues(alpha: 0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withValues(alpha: 0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: const Color(0xFFFFD700),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Up to ${reward.toInt()} VOID',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.play_circle_fill,
              color: color,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String gameName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              ),
              child: const Icon(
                Icons.sports_esports,
                color: Color(0xFF06B6D4),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              gameName,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'This exciting game is coming soon! Stay tuned for updates.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'GOT IT',
              style: TextStyle(color: Color(0xFF06B6D4)),
            ),
          ),
        ],
      ),
    );
  }
}
