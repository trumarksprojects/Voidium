import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class UserService extends ChangeNotifier {
  UserModel? _currentUser;
  SharedPreferences? _prefs;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadUser();
  }

  Future<void> _loadUser() async {
    final userJson = _prefs?.getString('current_user');
    if (userJson != null) {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      _currentUser = UserModel.fromMap(userMap);
      notifyListeners();
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    String? referralCode,
  }) async {
    try {
      // Generate unique user ID
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

      _currentUser = UserModel(
        id: userId,
        username: username,
        email: email,
        lastClaimTime: DateTime.now(),
        joinedDate: DateTime.now(),
        referredBy: referralCode,
      );

      await _saveUser();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Registration error: $e');
      }
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      // In a real app, this would authenticate with a backend
      // For demo, we'll just check if user exists locally
      await _loadUser();
      return _currentUser != null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Login error: $e');
      }
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _prefs?.remove('current_user');
    notifyListeners();
  }

  Future<void> updateUser(UserModel user) async {
    _currentUser = user;
    await _saveUser();
    notifyListeners();
  }

  Future<void> updateBalance(double newBalance) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(voidiumBalance: newBalance);
      await _saveUser();
      notifyListeners();
    }
  }

  Future<void> updateMiningRate(double newRate) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(miningRate: newRate);
      await _saveUser();
      notifyListeners();
    }
  }

  Future<void> updateLastClaimTime(DateTime time) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(lastClaimTime: time);
      await _saveUser();
      notifyListeners();
    }
  }

  Future<void> incrementReferrals() async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        totalReferrals: _currentUser!.totalReferrals + 1,
      );
      await _saveUser();
      notifyListeners();
    }
  }

  Future<void> _saveUser() async {
    if (_currentUser != null && _prefs != null) {
      final userJson = json.encode(_currentUser!.toMap());
      await _prefs!.setString('current_user', userJson);
    }
  }

  String generateReferralCode() {
    if (_currentUser != null) {
      return 'VOID_${_currentUser!.id.substring(_currentUser!.id.length - 8).toUpperCase()}';
    }
    return '';
  }
}
