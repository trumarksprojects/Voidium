import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../services/user_service.dart';
import '../../services/gamification_service.dart';
import '../auth/login_screen.dart';

class EnhancedProfileScreen extends StatefulWidget {
  const EnhancedProfileScreen({super.key});

  @override
  State<EnhancedProfileScreen> createState() => _EnhancedProfileScreenState();
}

class _EnhancedProfileScreenState extends State<EnhancedProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditingName = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _editName() async {
    final userService = context.read<UserService>();
    final user = userService.currentUser;
    if (user == null) return;

    _nameController.text = user.username;
    
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: const Color(0xFF8B5CF6).withValues(alpha: 0.5)),
        ),
        title: const Text(
          'Edit Username',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter new username',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF8B5CF6)),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _nameController.text),
            child: const Text('SAVE', style: TextStyle(color: Color(0xFF06B6D4))),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != user.username) {
      await userService.updateUser(user.copyWith(username: newName));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username updated successfully!'),
            backgroundColor: Color(0xFF06B6D4),
          ),
        );
      }
    }
  }

  void _showKYCDialog() {
    final user = context.read<UserService>().currentUser;
    if (user == null) return;

    String message;
    if (!user.kycEligible) {
      message = 'KYC verification is currently only available to selected users. You will be notified when you become eligible.';
    } else if (user.kycSubmitted && !user.kycApproved) {
      message = 'Your KYC submission is under review. We will notify you once it has been processed.';
    } else if (user.kycApproved) {
      message = 'Your account is verified! You have full access to all features including token withdrawals.';
    } else {
      message = 'You are eligible for KYC verification! Complete the process to unlock withdrawal privileges.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: const Color(0xFF8B5CF6).withValues(alpha: 0.5)),
        ),
        title: Row(
          children: [
            Icon(
              user.kycApproved ? Icons.verified : Icons.shield,
              color: user.kycApproved ? const Color(0xFF10B981) : const Color(0xFF06B6D4),
            ),
            const SizedBox(width: 12),
            const Text('KYC Status', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('GOT IT', style: TextStyle(color: Color(0xFF06B6D4))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final gamificationService = context.watch<GamificationService>();
    final user = userService.currentUser;
    final globalStats = gamificationService.globalStats;
    final format = NumberFormat('#,##0');
    final formatDecimal = NumberFormat('#,##0.00');

    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await userService.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(24),
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
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
                      ),
                    ),
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  
                  // Username with edit button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF06B6D4), size: 20),
                        onPressed: _editName,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Badges row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (user.isAdmin)
                        _buildBadge('ADMIN', const Color(0xFFFFD700)),
                      if (user.kycApproved)
                        _buildBadge('VERIFIED', const Color(0xFF10B981)),
                      if (user.dailyStreak >= 7)
                        _buildBadge('🔥 ${user.dailyStreak}', const Color(0xFFEC4899)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // KYC Status Button
            _buildKYCButton(user),
            const SizedBox(height: 16),

            // Token Information
            _buildTokenInfo(user, globalStats, formatDecimal),
            const SizedBox(height: 16),

            // Stats
            _buildStatCard(context, 'Level', user.level.toString(), Icons.trending_up),
            const SizedBox(height: 12),
            _buildStatCard(context, 'Total Referrals', user.totalReferrals.toString(), Icons.people),
            const SizedBox(height: 12),
            _buildStatCard(context, 'Mining Rate', '${user.miningRate} VOID/hour', Icons.speed),
            const SizedBox(height: 12),
            _buildStatCard(context, 'Daily Streak', '${user.dailyStreak} days', Icons.local_fire_department),
            const SizedBox(height: 24),

            // Referral section
            _buildReferralSection(userService),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildKYCButton(user) {
    Color buttonColor;
    IconData icon;
    String buttonText;

    if (user.kycApproved) {
      buttonColor = const Color(0xFF10B981);
      icon = Icons.verified;
      buttonText = 'KYC VERIFIED';
    } else if (user.kycSubmitted) {
      buttonColor = const Color(0xFFF59E0B);
      icon = Icons.pending;
      buttonText = 'KYC PENDING';
    } else if (user.kycEligible) {
      buttonColor = const Color(0xFF06B6D4);
      icon = Icons.shield;
      buttonText = 'VERIFY KYC';
    } else {
      buttonColor = Colors.white24;
      icon = Icons.lock;
      buttonText = 'KYC NOT ELIGIBLE';
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _showKYCDialog,
        icon: Icon(icon),
        label: Text(buttonText),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTokenInfo(user, globalStats, NumberFormat formatDecimal) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1F3A).withValues(alpha: 0.8),
            const Color(0xFF1A1F3A).withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                ),
                child: const Icon(Icons.info_outline, color: Color(0xFF06B6D4)),
              ),
              const SizedBox(width: 12),
              const Text(
                'Token Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Your Balance', '${formatDecimal.format(user.voidiumBalance)} VOID'),
          const SizedBox(height: 12),
          _buildInfoRow('Total Users', NumberFormat('#,##0').format(globalStats.totalUsers)),
          const SizedBox(height: 12),
          _buildInfoRow('Total Mined (Global)', '${formatDecimal.format(globalStats.totalVoidiumMined)} VOID'),
          const SizedBox(height: 12),
          _buildInfoRow('Active Miners', NumberFormat('#,##0').format(globalStats.activeMiners)),
          const SizedBox(height: 12),
          _buildInfoRow('Avg Mining Rate', '${globalStats.averageMiningRate} VOID/hour'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
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
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  const Color(0xFF06B6D4).withValues(alpha: 0.3),
                ],
              ),
            ),
            child: Icon(icon, color: const Color(0xFF06B6D4)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralSection(UserService userService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Referral Code',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E27),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    userService.generateReferralCode(),
                    style: const TextStyle(
                      color: Color(0xFF06B6D4),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  color: const Color(0xFF06B6D4),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: userService.generateReferralCode()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Referral code copied!'),
                        backgroundColor: Color(0xFF06B6D4),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Share.share(
                  'Join me on Voidium Miner and start earning crypto! Use my referral code: ${userService.generateReferralCode()}',
                );
              },
              icon: const Icon(Icons.share),
              label: const Text('SHARE CODE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06B6D4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
