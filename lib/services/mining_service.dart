import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_service.dart';

class MiningService extends ChangeNotifier {
  final UserService _userService;
  Timer? _miningTimer;
  double _pendingVoidium = 0.0;
  bool _isMining = false;

  MiningService(this._userService);

  bool get isMining => _isMining;
  double get pendingVoidium => _pendingVoidium;

  Future<void> init() async {
    await _loadPendingVoidium();
    startMining();
  }

  void startMining() {
    if (_userService.currentUser == null) return;

    _isMining = true;
    
    // Calculate pending voidium from last claim
    _calculatePendingVoidium();

    // Start mining timer (updates every second)
    _miningTimer?.cancel();
    _miningTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateMining();
    });
    
    notifyListeners();
  }

  void stopMining() {
    _isMining = false;
    _miningTimer?.cancel();
    notifyListeners();
  }

  void _calculatePendingVoidium() {
    final user = _userService.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final timeDiff = now.difference(user.lastClaimTime);
    final hoursElapsed = timeDiff.inSeconds / 3600.0;
    
    _pendingVoidium = hoursElapsed * user.miningRate;
    notifyListeners();
  }

  void _updateMining() {
    final user = _userService.currentUser;
    if (user == null || !_isMining) return;

    // Add voidium based on mining rate (per hour converted to per second)
    final voidiumPerSecond = user.miningRate / 3600.0;
    _pendingVoidium += voidiumPerSecond;
    
    notifyListeners();
  }

  Future<double> claimPendingVoidium() async {
    final user = _userService.currentUser;
    if (user == null) return 0.0;

    final claimedAmount = _pendingVoidium;
    
    // Update user balance
    final newBalance = user.voidiumBalance + claimedAmount;
    await _userService.updateBalance(newBalance);
    await _userService.updateLastClaimTime(DateTime.now());

    // Reset pending
    _pendingVoidium = 0.0;
    await _savePendingVoidium();
    
    notifyListeners();
    return claimedAmount;
  }

  Future<void> boostMiningRate(double multiplier, {int durationHours = 24}) async {
    final user = _userService.currentUser;
    if (user == null) return;

    final newRate = user.miningRate * multiplier;
    await _userService.updateMiningRate(newRate);
    
    // In a real app, you'd set a timer to reset the rate after duration
    notifyListeners();
  }

  Future<void> _loadPendingVoidium() async {
    final prefs = await SharedPreferences.getInstance();
    _pendingVoidium = prefs.getDouble('pending_voidium') ?? 0.0;
  }

  Future<void> _savePendingVoidium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('pending_voidium', _pendingVoidium);
  }

  @override
  void dispose() {
    _miningTimer?.cancel();
    super.dispose();
  }

  // Calculate estimated earnings
  double getEstimatedDaily() {
    final user = _userService.currentUser;
    if (user == null) return 0.0;
    return user.miningRate * 24;
  }

  double getEstimatedWeekly() {
    return getEstimatedDaily() * 7;
  }

  double getEstimatedMonthly() {
    return getEstimatedDaily() * 30;
  }
}
