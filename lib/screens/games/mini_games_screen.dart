import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tap_master_game.dart';
import 'crash_game.dart';
import '../../services/simple_advanced_features_service.dart';

class MiniGamesScreen extends StatelessWidget {
  const MiniGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Games'),
        centerTitle: true,
      ),
      body: Consumer<AdvancedFeaturesService>(
        builder: (context, advancedService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Energy Display
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
                  child: Column(
                    children: [
                      Row(
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
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0E27).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildEnergyInfo(
                              'Energy',
                              '${advancedService.energySystem.currentEnergy}/${advancedService.energySystem.maxEnergy}',
                              Icons.battery_charging_full,
                              Colors.green,
                            ),
                            _buildEnergyInfo(
                              'Regen Rate',
                              '1 per ${advancedService.energySystem.regenRateMinutes}min',
                              Icons.refresh,
                              const Color(0xFF06B6D4),
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
                  'Tap as fast as you can in 30 seconds!',
                  Icons.touch_app,
                  const Color(0xFF8B5CF6),
                  100.0,
                  10,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TapMasterGame()),
                  ),
                ),
                const SizedBox(height: 12),
                _buildGameCard(
                  context,
                  'Crash Game',
                  'Cash out before the rocket crashes!',
                  Icons.rocket_launch,
                  const Color(0xFFFF6B35),
                  500.0,
                  15,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CrashGame()),
                  ),
                ),
                const SizedBox(height: 12),
                _buildGameCard(
                  context,
                  'Memory Match',
                  'Match the crypto cards',
                  Icons.casino,
                  const Color(0xFF06B6D4),
                  150.0,
                  8,
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
                  5,
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
                  10,
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
                  12,
                  () => _showComingSoon(context, 'Puzzle Slider'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildEnergyInfo(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    double reward,
    int energyCost,
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
                      const SizedBox(width: 12),
                      Icon(
                        Icons.battery_charging_full,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$energyCost Energy',
                        style: const TextStyle(
                          color: Colors.orange,
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
