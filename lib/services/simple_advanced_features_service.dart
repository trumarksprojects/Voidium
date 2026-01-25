import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/energy_system.dart';
import '../services/user_service.dart';

// Simplified Advanced Features Service
class AdvancedFeaturesService extends ChangeNotifier {
  final UserService _userService;
  
  // Energy System
  EnergySystem _energySystem = EnergySystem(
    currentEnergy: 100,
    maxEnergy: 100,
    lastRegenTime: DateTime.now(),
    regenRateMinutes: 5,
  );
  
  AdvancedFeaturesService(this._userService) {
    _initialize();
  }
  
  // Getters
  EnergySystem get energySystem => _energySystem;
  
  Future<void> _initialize() async {
    await _loadEnergySystem();
    notifyListeners();
  }
  
  // ========== ENERGY SYSTEM ==========
  
  Future<void> _loadEnergySystem() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final energyData = prefs.getString('energy_system');
      if (energyData != null) {
        final Map<String, dynamic> json = jsonDecode(energyData);
        _energySystem = EnergySystem.fromJson(json);
        _regenerateEnergy();
      }
    } catch (e) {
      if (kDebugMode) print('Error loading energy system: $e');
    }
  }
  
  Future<void> _saveEnergySystem() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('energy_system', jsonEncode(_energySystem.toJson()));
    } catch (e) {
      if (kDebugMode) print('Error saving energy system: $e');
    }
  }
  
  void _regenerateEnergy() {
    final now = DateTime.now();
    final minutesPassed = now.difference(_energySystem.lastRegenTime).inMinutes;
    final energyToAdd = (minutesPassed / _energySystem.regenRateMinutes).floor();
    
    if (energyToAdd > 0) {
      _energySystem = EnergySystem(
        currentEnergy: min(
          _energySystem.currentEnergy + energyToAdd,
          _energySystem.maxEnergy,
        ),
        maxEnergy: _energySystem.maxEnergy,
        lastRegenTime: now,
        regenRateMinutes: _energySystem.regenRateMinutes,
      );
      _saveEnergySystem();
    }
  }
  
  Future<bool> consumeEnergy(int amount) async {
    _regenerateEnergy();
    
    if (_energySystem.currentEnergy >= amount) {
      _energySystem = EnergySystem(
        currentEnergy: _energySystem.currentEnergy - amount,
        maxEnergy: _energySystem.maxEnergy,
        lastRegenTime: _energySystem.lastRegenTime,
        regenRateMinutes: _energySystem.regenRateMinutes,
      );
      await _saveEnergySystem();
      notifyListeners();
      return true;
    }
    return false;
  }
  
  Future<void> restoreEnergyWithAd() async {
    await Future.delayed(const Duration(seconds: 1));
    _energySystem = EnergySystem(
      currentEnergy: min(
        _energySystem.currentEnergy + 20,
        _energySystem.maxEnergy,
      ),
      maxEnergy: _energySystem.maxEnergy,
      lastRegenTime: _energySystem.lastRegenTime,
      regenRateMinutes: _energySystem.regenRateMinutes,
    );
    await _saveEnergySystem();
    notifyListeners();
  }
  
  Future<void> restoreFullEnergy() async {
    _energySystem = EnergySystem(
      currentEnergy: _energySystem.maxEnergy,
      maxEnergy: _energySystem.maxEnergy,
      lastRegenTime: DateTime.now(),
      regenRateMinutes: _energySystem.regenRateMinutes,
    );
    await _saveEnergySystem();
    notifyListeners();
  }
}
