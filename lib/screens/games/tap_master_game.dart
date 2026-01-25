import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../services/simple_advanced_features_service.dart';
import '../../services/user_service.dart';

class TapMasterGame extends StatefulWidget {
  const TapMasterGame({super.key});

  @override
  State<TapMasterGame> createState() => _TapMasterGameState();
}

class _TapMasterGameState extends State<TapMasterGame> with TickerProviderStateMixin {
  int _tapCount = 0;
  int _timeLeft = 30;
  bool _isPlaying = false;
  bool _gameEnded = false;
  Timer? _timer;
  double _score = 0.0;
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _scoreController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scoreAnimation;
  
  // Tap animation
  List<TapEffect> _tapEffects = [];
  
  final int _energyCost = 10;
  final int _gameDuration = 30; // seconds
  
  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.elasticOut),
    );
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _scoreController.dispose();
    super.dispose();
  }
  
  void _startGame() async {
    final advancedService = Provider.of<AdvancedFeaturesService>(context, listen: false);
    
    // Check energy
    if (!await advancedService.consumeEnergy(_energyCost)) {
      _showEnergyDialog();
      return;
    }
    
    setState(() {
      _isPlaying = true;
      _gameEnded = false;
      _tapCount = 0;
      _timeLeft = _gameDuration;
      _score = 0.0;
      _tapEffects.clear();
    });
    
    // Start countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _endGame();
        }
      });
    });
  }
  
  void _endGame() {
    _timer?.cancel();
    
    setState(() {
      _isPlaying = false;
      _gameEnded = true;
    });
    
    // Calculate score and rewards
    _calculateRewards();
  }
  
  void _calculateRewards() async {
    // Score calculation: base 10 VOID per tap + bonus for speed
    final tapsPerSecond = _tapCount / _gameDuration;
    double baseReward = _tapCount * 10.0;
    double speedBonus = 0.0;
    
    if (tapsPerSecond > 3) {
      speedBonus = baseReward * 0.5; // 50% bonus
    } else if (tapsPerSecond > 2) {
      speedBonus = baseReward * 0.25; // 25% bonus
    }
    
    _score = baseReward + speedBonus;
    
    // Award to user
    final userService = Provider.of<UserService>(context, listen: false);
    await userService.updateUser(
      userService.currentUser!.copyWith(
        voidiumBalance: userService.currentUser!.voidiumBalance + _score,
      ),
    );
    
    if (!mounted) return;
    // Show results
    _showResultsDialog();
  }
  
  void _handleTap(TapDownDetails details) {
    if (!_isPlaying) return;
    
    setState(() {
      _tapCount++;
      
      // Add tap effect
      _tapEffects.add(TapEffect(
        position: details.localPosition,
        timestamp: DateTime.now(),
      ));
      
      // Remove old effects
      _tapEffects.removeWhere((effect) => 
        DateTime.now().difference(effect.timestamp).inMilliseconds > 1000);
    });
    
    // Trigger score animation
    _scoreController.forward(from: 0.0);
  }
  
  void _showEnergyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.battery_alert, color: Colors.orange[400], size: 28),
            const SizedBox(width: 12),
            const Text('Not Enough Energy', 
              style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Text(
          'You need $_energyCost energy to play Tap Master.\n\nWatch an ad to restore 20 energy or wait for natural regeneration.',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final advancedService = Provider.of<AdvancedFeaturesService>(context, listen: false);
              await advancedService.restoreEnergyWithAd();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Energy restored! +20 energy'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Watch Ad'),
          ),
        ],
      ),
    );
  }
  
  void _showResultsDialog() {
    final tapsPerSecond = (_tapCount / _gameDuration).toStringAsFixed(2);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Game Over!', 
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    '$_tapCount TAPS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$tapsPerSecond taps/sec',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total Taps', '$_tapCount', Icons.touch_app),
                _buildStatCard('Reward', '${_score.toStringAsFixed(0)} VOID', Icons.monetization_on),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to games screen
            },
            child: const Text('Exit', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E27).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF8B5CF6), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Tap Master', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AdvancedFeaturesService>(
        builder: (context, advancedService, child) {
          return SafeArea(
            child: Column(
              children: [
                // Energy and Timer Bar
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                        const Color(0xFF06B6D4).withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(
                        'Energy',
                        '${advancedService.energySystem.currentEnergy}/${advancedService.energySystem.maxEnergy}',
                        Icons.battery_charging_full,
                        Colors.green,
                      ),
                      _buildInfoItem(
                        'Time',
                        '$_timeLeft s',
                        Icons.timer,
                        _isPlaying ? Colors.orange : Colors.grey,
                      ),
                      _buildInfoItem(
                        'Taps',
                        '$_tapCount',
                        Icons.touch_app,
                        const Color(0xFF06B6D4),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Game Area
                Expanded(
                  child: GestureDetector(
                    onTapDown: _isPlaying ? _handleTap : null,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                            const Color(0xFF0A0E27),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isPlaying 
                            ? const Color(0xFF8B5CF6) 
                            : Colors.grey.withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Tap effects
                          ..._tapEffects.map((effect) => _buildTapEffect(effect)),
                          
                          // Center content
                          Center(
                            child: _isPlaying
                              ? ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(40),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF8B5CF6),
                                              const Color(0xFF06B6D4),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                                              blurRadius: 30,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.touch_app,
                                          size: 80,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      ScaleTransition(
                                        scale: _scoreAnimation,
                                        child: Text(
                                          'TAP!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                color: const Color(0xFF8B5CF6),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : _gameEnded
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        size: 80,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Game Complete!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.play_circle_outline,
                                        size: 80,
                                        color: Color(0xFF8B5CF6),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Tap Start to Play',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Cost: $_energyCost Energy',
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Start Button
                if (!_isPlaying && !_gameEnded)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'START GAME',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }
  
  Widget _buildTapEffect(TapEffect effect) {
    final age = DateTime.now().difference(effect.timestamp).inMilliseconds;
    final opacity = 1.0 - (age / 1000);
    final scale = 1.0 + (age / 500);
    
    return Positioned(
      left: effect.position.dx - 15,
      top: effect.position.dy - 15,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: scale,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF06B6D4).withValues(alpha: 0.6),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Center(
              child: Text(
                '+1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TapEffect {
  final Offset position;
  final DateTime timestamp;
  
  TapEffect({required this.position, required this.timestamp});
}
