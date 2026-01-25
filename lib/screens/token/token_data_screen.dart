import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../services/user_service.dart';
import '../../services/gamification_service.dart';

class TokenDataScreen extends StatelessWidget {
  const TokenDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final gamificationService = context.watch<GamificationService>();
    final user = userService.currentUser;
    final globalStats = gamificationService.globalStats;
    final format = NumberFormat('#,##0');

    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Token Data'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Token Data Header
            const Text(
              'Token Data',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Legend
            _buildLegend(),
            const SizedBox(height: 24),

            // Chart Area (Simulated)
            _buildChartArea(),
            const SizedBox(height: 24),

            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Verified VOID',
                    format.format(globalStats.totalVoidiumMined),
                    const Color(0xFF06B6D4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Verifying VOID',
                    format.format(globalStats.totalVoidiumMined * 1.78),
                    const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Token Metrics
            _buildTokenMetrics(user, globalStats, format),
            const SizedBox(height: 24),

            // Mining vs Buyback Info
            _buildMiningBuybackInfo(format),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLegendItem('Verified ATOS:', '?', const Color(0xFF8B5CF6)),
          const SizedBox(height: 8),
          _buildLegendItem('Mined Token', '', const Color(0xFF06B6D4)),
          const SizedBox(height: 8),
          _buildLegendItem('Buyback Token', '', const Color(0xFFFFB020)),
          const SizedBox(height: 8),
          _buildLegendItem(
            'The difference between Mined and Buyback',
            '',
            const Color(0xFF0A4A6B),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String suffix, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        if (suffix.isNotEmpty) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              suffix,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChartArea() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(
        painter: TokenChartPainter(),
        size: const Size(double.infinity, 300),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenMetrics(user, globalStats, NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            const Color(0xFF06B6D4).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Token Metrics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricRow('Your Balance', '${format.format(user.voidiumBalance)} VOID'),
          _buildMetricRow('Mining Rate', '${user.miningRate} VOID/hour'),
          _buildMetricRow('Total Users', format.format(globalStats.totalUsers)),
          _buildMetricRow('Active Miners', format.format(globalStats.activeMiners)),
          _buildMetricRow('Circulation Supply', '${format.format(globalStats.totalVoidiumMined * 0.6)} VOID'),
          _buildMetricRow('Locked Supply', '${format.format(globalStats.totalVoidiumMined * 0.4)} VOID'),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF06B6D4),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiningBuybackInfo(NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF06B6D4)),
              const SizedBox(width: 8),
              const Text(
                'Token Economics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Mining represents tokens generated through user activities and rewards. '
            'Buyback represents tokens repurchased from the market to maintain value stability.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class TokenChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint1 = Paint()
      ..color = const Color(0xFF06B6D4)
      ..style = PaintingStyle.fill;
    final paint2 = Paint()
      ..color = const Color(0xFFFFB020)
      ..style = PaintingStyle.fill;
    final paint3 = Paint()
      ..color = const Color(0xFF0A4A6B)
      ..style = PaintingStyle.fill;

    // Generate random data points
    final points1 = <Offset>[];
    final points2 = <Offset>[];
    final points3 = <Offset>[];

    for (var i = 0; i < 100; i++) {
      final x = (i / 100) * size.width;
      final y1 = size.height * 0.3 + random.nextDouble() * size.height * 0.4;
      final y2 = size.height * 0.5 + random.nextDouble() * size.height * 0.3;
      final y3 = y1 - y2;

      points1.add(Offset(x, y1));
      points2.add(Offset(x, y2));
      points3.add(Offset(x, y3.abs()));
    }

    // Draw mined token area (blue)
    final path1 = Path()..moveTo(0, size.height);
    for (var point in points1) {
      path1.lineTo(point.dx, point.dy);
    }
    path1.lineTo(size.width, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Draw buyback token area (orange)
    final path2 = Path()..moveTo(0, size.height);
    for (var point in points2) {
      path2.lineTo(point.dx, point.dy);
    }
    path2.lineTo(size.width, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);

    // Draw difference area (dark blue)
    final path3 = Path()..moveTo(0, size.height);
    for (var i = 0; i < points3.length; i++) {
      path3.lineTo(points3[i].dx, size.height - points3[i].dy);
    }
    path3.lineTo(size.width, size.height);
    path3.close();
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
