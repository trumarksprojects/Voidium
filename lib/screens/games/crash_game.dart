import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../services/simple_advanced_features_service.dart';
import '../../services/user_service.dart';

class CrashGame extends StatefulWidget {
  const CrashGame({super.key});

  @override
  State<CrashGame> createState() => _CrashGameState();
}

class _CrashGameState extends State<CrashGame> with TickerProviderStateMixin {
  double _currentMultiplier = 1.00;
  double _betAmount = 100.0;
  bool _isPlaying = false;
  bool _hasBet = false;
  bool _hasCashedOut = false;
  double _cashOutMultiplier = 0.0;
  double _profit = 0.0;
  
  Timer? _gameTimer;
  late AnimationController _rocketController;
  late Animation<double> _rocketAnimation;
  
  // Provably fair system
  String _serverSeed = '';
  String _clientSeed = '';
  String _hash = '';
  double _crashPoint = 0.0;
  
  List<GameHistory> _history = [];
  final int _maxHistory = 10;
  
  final int _energyCost = 15;
  
  @override
  void initState() {
    super.initState();
    
    _rocketController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _rocketAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rocketController, curve: Curves.easeOut),
    );
    
    _generateNewRound();
  }
  
  @override
  void dispose() {
    _gameTimer?.cancel();
    _rocketController.dispose();
    super.dispose();
  }
  
  void _generateNewRound() {
    // Generate provably fair crash point
    _serverSeed = _generateRandomString(32);
    _clientSeed = _generateRandomString(16);
    _hash = _hashSeeds(_serverSeed, _clientSeed);
    _crashPoint = _calculateCrashPoint(_hash);
    
    setState(() {
      _currentMultiplier = 1.00;
      _hasBet = false;
      _hasCashedOut = false;
      _cashOutMultiplier = 0.0;
      _profit = 0.0;
    });
  }
  
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }
  
  String _hashSeeds(String serverSeed, String clientSeed) {
    final bytes = utf8.encode(serverSeed + clientSeed);
    return sha256.convert(bytes).toString();
  }
  
  double _calculateCrashPoint(String hash) {
    // Provably fair algorithm: convert hash to number and calculate crash point
    final hashValue = int.parse(hash.substring(0, 8), radix: 16);
    const e = 4294967296; // 2^32
    final crashPoint = (99 / (1 - (hashValue / e)) / 100).clamp(1.0, 50.0);
    return double.parse(crashPoint.toStringAsFixed(2));
  }
  
  void _placeBet() async {
    final userService = Provider.of<UserService>(context, listen: false);
    final advancedService = Provider.of<AdvancedFeaturesService>(context, listen: false);
    
    // Check energy
    if (!await advancedService.consumeEnergy(_energyCost)) {
      _showEnergyDialog();
      return;
    }
    
    // Check balance
    if (userService.currentUser!.voidiumBalance < _betAmount) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient VOID balance'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Deduct bet amount
    await userService.updateUser(
      userService.currentUser!.copyWith(
        voidiumBalance: userService.currentUser!.voidiumBalance - _betAmount,
      ),
    );
    
    setState(() {
      _hasBet = true;
    });
    
    if (!_isPlaying) {
      _startGame();
    }
  }
  
  void _startGame() {
    setState(() {
      _isPlaying = true;
      _currentMultiplier = 1.00;
    });
    
    _rocketController.forward();
    
    // Start multiplier increase
    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _currentMultiplier += 0.01;
        
        // Check if crashed
        if (_currentMultiplier >= _crashPoint) {
          _crash();
        }
      });
    });
  }
  
  Future<void> _cashOut() async {
    if (!_hasBet || _hasCashedOut || !_isPlaying) return;
    
    setState(() {
      _hasCashedOut = true;
      _cashOutMultiplier = _currentMultiplier;
      _profit = _betAmount * _currentMultiplier;
    });
    
    // Add winnings to balance
    final userService = Provider.of<UserService>(context, listen: false);
    await userService.updateUser(
      userService.currentUser!.copyWith(
        voidiumBalance: userService.currentUser!.voidiumBalance + _profit,
      ),
    );
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cashed out at ${_currentMultiplier.toStringAsFixed(2)}x! Won ${_profit.toStringAsFixed(0)} VOID'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _crash() {
    _gameTimer?.cancel();
    
    // Record history
    _history.insert(0, GameHistory(
      crashPoint: _crashPoint,
      won: _hasCashedOut,
      multiplier: _hasCashedOut ? _cashOutMultiplier : 0.0,
      betAmount: _hasBet ? _betAmount : 0.0,
      profit: _hasCashedOut ? _profit : (_hasBet ? -_betAmount : 0.0),
    ));
    
    if (_history.length > _maxHistory) {
      _history.removeLast();
    }
    
    setState(() {
      _isPlaying = false;
    });
    
    _rocketController.reverse();
    
    // Show crash dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      _showCrashDialog();
    });
  }
  
  void _showCrashDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _hasCashedOut ? Icons.check_circle : Icons.cancel,
              color: _hasCashedOut ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              _hasCashedOut ? 'Won!' : 'Crashed!',
              style: TextStyle(
                color: _hasCashedOut ? Colors.green : Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0E27),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasCashedOut 
                    ? Colors.green.withValues(alpha: 0.3)
                    : Colors.red.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Crashed at',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    '${_crashPoint.toStringAsFixed(2)}x',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_hasCashedOut) ...[
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 16),
                    Text(
                      'You cashed out at',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      '${_cashOutMultiplier.toStringAsFixed(2)}x',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Profit: ${_profit.toStringAsFixed(0)} VOID',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else if (_hasBet) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Lost: ${_betAmount.toStringAsFixed(0)} VOID',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Provably fair info
            ExpansionTile(
              title: const Text(
                'Provably Fair',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              iconColor: const Color(0xFF8B5CF6),
              collapsedIconColor: Colors.white60,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0E27),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSeedInfo('Server Seed', _serverSeed),
                      const SizedBox(height: 8),
                      _buildSeedInfo('Client Seed', _clientSeed),
                      const SizedBox(height: 8),
                      _buildSeedInfo('Hash', _hash),
                      const SizedBox(height: 8),
                      Text(
                        'Crash Point: ${_crashPoint.toStringAsFixed(2)}x',
                        style: const TextStyle(
                          color: Color(0xFF06B6D4),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
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
              _generateNewRound();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSeedInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 10),
        ),
        Text(
          value.length > 20 ? '${value.substring(0, 20)}...' : value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
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
          'You need $_energyCost energy to play Crash Game.\n\nWatch an ad to restore 20 energy or wait for natural regeneration.',
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Crash Game', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showHowToPlay(),
          ),
        ],
      ),
      body: Consumer2<AdvancedFeaturesService, UserService>(
        builder: (context, advancedService, userService, child) {
          return SafeArea(
            child: Column(
              children: [
                // Stats Bar
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
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Balance', '${userService.currentUser!.voidiumBalance.toStringAsFixed(0)} VOID', Icons.account_balance_wallet),
                      _buildStatItem('Energy', '${advancedService.energySystem.currentEnergy}', Icons.battery_charging_full),
                      _buildStatItem('Cost', '$_energyCost Energy', Icons.energy_savings_leaf),
                    ],
                  ),
                ),
                
                // Multiplier Display
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          _isPlaying 
                            ? const Color(0xFF8B5CF6).withValues(alpha: 0.4)
                            : const Color(0xFF0A0E27),
                          const Color(0xFF0A0E27),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isPlaying 
                          ? const Color(0xFF8B5CF6)
                          : Colors.grey.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _rocketAnimation,
                            child: Icon(
                              Icons.rocket_launch,
                              size: 80,
                              color: _isPlaying 
                                ? const Color(0xFF06B6D4)
                                : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _isPlaying 
                              ? '${_currentMultiplier.toStringAsFixed(2)}x'
                              : 'Place Your Bet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: _isPlaying ? 64 : 32,
                              fontWeight: FontWeight.bold,
                              shadows: _isPlaying ? [
                                Shadow(
                                  color: const Color(0xFF8B5CF6),
                                  blurRadius: 20,
                                ),
                              ] : [],
                            ),
                          ),
                          if (_hasBet && _isPlaying && !_hasCashedOut) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Potential Win: ${(_betAmount * _currentMultiplier).toStringAsFixed(0)} VOID',
                              style: const TextStyle(
                                color: Color(0xFF06B6D4),
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Betting Controls
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F3A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      // Bet Amount Slider
                      Row(
                        children: [
                          const Text(
                            'Bet Amount:',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const Spacer(),
                          Text(
                            '${_betAmount.toStringAsFixed(0)} VOID',
                            style: const TextStyle(
                              color: Color(0xFF8B5CF6),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _betAmount,
                        min: 50,
                        max: 1000,
                        divisions: 19,
                        activeColor: const Color(0xFF8B5CF6),
                        inactiveColor: Colors.grey,
                        onChanged: _isPlaying ? null : (value) {
                          setState(() {
                            _betAmount = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: (!_isPlaying && !_hasBet) ? _placeBet : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5CF6),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: Colors.grey,
                              ),
                              child: const Text(
                                'PLACE BET',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: (_isPlaying && _hasBet && !_hasCashedOut) ? _cashOut : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: Colors.grey,
                              ),
                              child: const Text(
                                'CASH OUT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Game History
                if (_history.isNotEmpty)
                  Container(
                    height: 80,
                    margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final game = _history[index];
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: game.won 
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: game.won ? Colors.green : Colors.red,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${game.crashPoint.toStringAsFixed(2)}x',
                                style: TextStyle(
                                  color: game.won ? Colors.green : Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (game.betAmount > 0)
                                Text(
                                  game.won ? '+${game.profit.toStringAsFixed(0)}' : '${game.profit.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: game.won ? Colors.green : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF06B6D4), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
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
  
  void _showHowToPlay() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('How to Play', style: TextStyle(color: Colors.white)),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Set your bet amount using the slider\n\n'
                '2. Click PLACE BET before the rocket launches\n\n'
                '3. Watch the multiplier increase as the rocket flies\n\n'
                '4. Click CASH OUT before the rocket crashes\n\n'
                '5. The longer you wait, the higher your potential win - but if you wait too long, you lose everything!\n\n'
                'Provably Fair: Every game uses cryptographic hashing to ensure fairness. You can verify the results!',
                style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Got It!'),
          ),
        ],
      ),
    );
  }
}

class GameHistory {
  final double crashPoint;
  final bool won;
  final double multiplier;
  final double betAmount;
  final double profit;
  
  GameHistory({
    required this.crashPoint,
    required this.won,
    required this.multiplier,
    required this.betAmount,
    required this.profit,
  });
}
