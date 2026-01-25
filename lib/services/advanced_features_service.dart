import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/advanced_features_models.dart';
import '../services/user_service.dart';

class AdvancedFeaturesService extends ChangeNotifier {
  final UserService _userService;
  
  // Energy System
  EnergySystem _energySystem = EnergySystem(
    currentEnergy: 100,
    maxEnergy: 100,
    lastRegenTime: DateTime.now(),
    regenRateMinutes: 5, // 1 energy every 5 minutes
  );
  
  // Battle Pass
  BattlePass? _currentBattlePass;
  List<BattlePassTier> _battlePassTiers = [];
  
  // Loot Boxes
  List<LootBox> _availableLootBoxes = [];
  List<LootBox> _userLootBoxes = [];
  
  // In-App Purchases
  List<InAppPurchase> _availablePurchases = [];
  String _paymentWalletAddress = '';
  
  // Purchase History
  List<PurchaseHistory> _purchaseHistory = [];
  
  AdvancedFeaturesService(this._userService) {
    _initialize();
  }
  
  // Getters
  EnergySystem get energySystem => _energySystem;
  BattlePass? get currentBattlePass => _currentBattlePass;
  List<BattlePassTier> get battlePassTiers => _battlePassTiers;
  List<LootBox> get availableLootBoxes => _availableLootBoxes;
  List<LootBox> get userLootBoxes => _userLootBoxes;
  List<InAppPurchase> get availablePurchases => _availablePurchases;
  String get paymentWalletAddress => _paymentWalletAddress;
  List<PurchaseHistory> get purchaseHistory => _purchaseHistory;
  
  Future<void> _initialize() async {
    await _loadEnergySystem();
    await _loadBattlePass();
    await _loadLootBoxes();
    await _loadPurchases();
    _initializeDefaultFeatures();
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
        // Regenerate energy since last load
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
    // Simulate watching ad (integrate with AdService)
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
  
  // ========== BATTLE PASS ==========
  
  Future<void> _loadBattlePass() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final battlePassData = prefs.getString('battle_pass');
      if (battlePassData != null) {
        final Map<String, dynamic> json = jsonDecode(battlePassData);
        _currentBattlePass = BattlePass.fromJson(json);
      }
      
      final tiersData = prefs.getString('battle_pass_tiers');
      if (tiersData != null) {
        final List<dynamic> jsonList = jsonDecode(tiersData);
        _battlePassTiers = jsonList.map((json) => BattlePassTier.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) print('Error loading battle pass: $e');
    }
  }
  
  Future<void> _saveBattlePass() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentBattlePass != null) {
        await prefs.setString('battle_pass', jsonEncode(_currentBattlePass!.toJson()));
      }
      await prefs.setString('battle_pass_tiers', 
        jsonEncode(_battlePassTiers.map((tier) => tier.toJson()).toList()));
    } catch (e) {
      if (kDebugMode) print('Error saving battle pass: $e');
    }
  }
  
  Future<void> createSeasonalBattlePass(String seasonName, DateTime endDate) async {
    _currentBattlePass = BattlePass(
      id: 'bp_${DateTime.now().millisecondsSinceEpoch}',
      seasonName: seasonName,
      currentTier: 0,
      xp: 0,
      isPremium: false,
      startDate: DateTime.now(),
      endDate: endDate,
    );
    
    // Create 30 tiers with increasing rewards
    _battlePassTiers = List.generate(30, (index) {
      final tier = index + 1;
      return BattlePassTier(
        tier: tier,
        xpRequired: tier * 1000,
        freeReward: BattlePassReward(
          type: 'VOID',
          amount: tier * 50.0,
          name: '${tier * 50} VOID',
        ),
        premiumReward: BattlePassReward(
          type: 'VOID',
          amount: tier * 150.0,
          name: '${tier * 150} VOID + Exclusive Badge',
        ),
      );
    });
    
    await _saveBattlePass();
    notifyListeners();
  }
  
  Future<void> addBattlePassXP(int xp) async {
    if (_currentBattlePass == null) return;
    
    _currentBattlePass!.xp += xp;
    
    // Check for tier ups
    while (_currentBattlePass!.currentTier < _battlePassTiers.length) {
      final nextTier = _battlePassTiers[_currentBattlePass!.currentTier];
      if (_currentBattlePass!.xp >= nextTier.xpRequired) {
        _currentBattlePass!.currentTier++;
        // Award rewards
        await _awardBattlePassReward(nextTier);
      } else {
        break;
      }
    }
    
    await _saveBattlePass();
    notifyListeners();
  }
  
  Future<void> _awardBattlePassReward(BattlePassTier tier) async {
    final reward = _currentBattlePass!.isPremium ? tier.premiumReward : tier.freeReward;
    if (reward.type == 'VOID') {
      await _userService.updateUser(_userService.currentUser!.copyWith(
        balance: _userService.currentUser!.balance + reward.amount,
      ));
    }
  }
  
  Future<bool> upgradeToPremiumBattlePass(double usdPrice) async {
    if (_currentBattlePass == null || _currentBattlePass!.isPremium) {
      return false;
    }
    
    // Here you would integrate with payment system
    // For now, simulate purchase
    _currentBattlePass!.isPremium = true;
    
    // Award all previous premium rewards
    for (int i = 0; i < _currentBattlePass!.currentTier; i++) {
      await _awardBattlePassReward(_battlePassTiers[i]);
    }
    
    await _saveBattlePass();
    notifyListeners();
    return true;
  }
  
  // ========== LOOT BOXES ==========
  
  Future<void> _loadLootBoxes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lootBoxesData = prefs.getString('user_loot_boxes');
      if (lootBoxesData != null) {
        final List<dynamic> jsonList = jsonDecode(lootBoxesData);
        _userLootBoxes = jsonList.map((json) => LootBox.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) print('Error loading loot boxes: $e');
    }
  }
  
  Future<void> _saveLootBoxes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_loot_boxes', 
        jsonEncode(_userLootBoxes.map((box) => box.toJson()).toList()));
    } catch (e) {
      if (kDebugMode) print('Error saving loot boxes: $e');
    }
  }
  
  void _initializeDefaultLootBoxes() {
    _availableLootBoxes = [
      LootBox(
        id: 'common_box',
        name: 'Common Box',
        rarity: 'Common',
        price: 5.0,
        priceType: 'USD',
        possibleRewards: [
          LootBoxReward(type: 'VOID', minAmount: 100, maxAmount: 500, probability: 0.8),
          LootBoxReward(type: 'Energy', minAmount: 10, maxAmount: 30, probability: 0.15),
          LootBoxReward(type: 'Boost2x', minAmount: 1, maxAmount: 1, probability: 0.05),
        ],
      ),
      LootBox(
        id: 'rare_box',
        name: 'Rare Box',
        rarity: 'Rare',
        price: 15.0,
        priceType: 'USD',
        possibleRewards: [
          LootBoxReward(type: 'VOID', minAmount: 500, maxAmount: 2000, probability: 0.6),
          LootBoxReward(type: 'Boost2x', minAmount: 1, maxAmount: 3, probability: 0.25),
          LootBoxReward(type: 'Boost5x', minAmount: 1, maxAmount: 1, probability: 0.1),
          LootBoxReward(type: 'BattlePassXP', minAmount: 500, maxAmount: 1000, probability: 0.05),
        ],
      ),
      LootBox(
        id: 'epic_box',
        name: 'Epic Box',
        rarity: 'Epic',
        price: 30.0,
        priceType: 'USD',
        possibleRewards: [
          LootBoxReward(type: 'VOID', minAmount: 2000, maxAmount: 5000, probability: 0.5),
          LootBoxReward(type: 'Boost5x', minAmount: 1, maxAmount: 3, probability: 0.3),
          LootBoxReward(type: 'Boost10x', minAmount: 1, maxAmount: 1, probability: 0.15),
          LootBoxReward(type: 'PremiumPass', minAmount: 1, maxAmount: 1, probability: 0.05),
        ],
      ),
      LootBox(
        id: 'legendary_box',
        name: 'Legendary Box',
        rarity: 'Legendary',
        price: 50.0,
        priceType: 'USD',
        possibleRewards: [
          LootBoxReward(type: 'VOID', minAmount: 5000, maxAmount: 15000, probability: 0.6),
          LootBoxReward(type: 'Boost10x', minAmount: 1, maxAmount: 5, probability: 0.25),
          LootBoxReward(type: 'PremiumPass', minAmount: 1, maxAmount: 1, probability: 0.1),
          LootBoxReward(type: 'VIPUpgrade', minAmount: 1, maxAmount: 1, probability: 0.05),
        ],
      ),
    ];
  }
  
  Future<LootBoxReward?> openLootBox(String boxId) async {
    final boxIndex = _userLootBoxes.indexWhere((box) => box.id == boxId);
    if (boxIndex == -1) return null;
    
    final box = _userLootBoxes[boxIndex];
    if (box.isOpened) return null;
    
    // Calculate reward based on probability
    final random = Random();
    final roll = random.nextDouble();
    
    double cumulativeProbability = 0.0;
    LootBoxReward? selectedReward;
    
    for (final reward in box.possibleRewards) {
      cumulativeProbability += reward.probability;
      if (roll <= cumulativeProbability) {
        selectedReward = reward;
        break;
      }
    }
    
    if (selectedReward != null) {
      // Calculate actual amount
      final amount = (selectedReward.minAmount + 
        random.nextInt(selectedReward.maxAmount - selectedReward.minAmount + 1)).toDouble();
      
      final actualReward = LootBoxReward(
        type: selectedReward.type,
        minAmount: amount.toInt(),
        maxAmount: amount.toInt(),
        probability: selectedReward.probability,
      );
      
      // Award the reward
      await _applyLootBoxReward(actualReward);
      
      // Mark box as opened
      box.isOpened = true;
      box.openedAt = DateTime.now();
      await _saveLootBoxes();
      notifyListeners();
      
      return actualReward;
    }
    
    return null;
  }
  
  Future<void> _applyLootBoxReward(LootBoxReward reward) async {
    switch (reward.type) {
      case 'VOID':
        await _userService.updateUser(_userService.currentUser!.copyWith(
          balance: _userService.currentUser!.balance + reward.minAmount,
        ));
        break;
      case 'Energy':
        _energySystem.currentEnergy = min(
          _energySystem.currentEnergy + reward.minAmount,
          _energySystem.maxEnergy,
        );
        await _saveEnergySystem();
        break;
      case 'BattlePassXP':
        await addBattlePassXP(reward.minAmount);
        break;
      // Add other reward types as needed
    }
  }
  
  // ========== IN-APP PURCHASES ==========
  
  Future<void> _loadPurchases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _paymentWalletAddress = prefs.getString('payment_wallet_address') ?? '';
      
      final historyData = prefs.getString('purchase_history');
      if (historyData != null) {
        final List<dynamic> jsonList = jsonDecode(historyData);
        _purchaseHistory = jsonList.map((json) => PurchaseHistory.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) print('Error loading purchases: $e');
    }
  }
  
  Future<void> _savePurchases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('payment_wallet_address', _paymentWalletAddress);
      await prefs.setString('purchase_history', 
        jsonEncode(_purchaseHistory.map((p) => p.toJson()).toList()));
    } catch (e) {
      if (kDebugMode) print('Error saving purchases: $e');
    }
  }
  
  void _initializeDefaultPurchases() {
    _availablePurchases = [
      InAppPurchase(
        id: 'ad_free_24h',
        name: 'Ad-Free Mining (24 Hours)',
        description: 'Mine without interruptions for 24 hours',
        priceUSD: 2.99,
        priceType: 'USD',
        duration: const Duration(hours: 24),
        benefits: ['No ads for 24 hours', 'Uninterrupted mining'],
      ),
      InAppPurchase(
        id: 'double_rewards_24h',
        name: 'Double Rewards Pass (24 Hours)',
        description: 'All rewards doubled for 24 hours',
        priceUSD: 4.99,
        priceType: 'USD',
        duration: const Duration(hours: 24),
        benefits: ['2x mining rewards', '2x task rewards', '2x referral bonuses'],
      ),
      InAppPurchase(
        id: 'accelerator_pack',
        name: 'Accelerator Pack',
        description: 'Instantly claim all pending offline mining rewards',
        priceUSD: 3.99,
        priceType: 'USD',
        benefits: ['Instant offline rewards', 'No waiting time'],
      ),
      InAppPurchase(
        id: 'energy_bundle_100',
        name: 'Energy Bundle (100)',
        description: '100 Energy for mini games',
        priceUSD: 1.99,
        priceType: 'USD',
        benefits: ['100 Energy instantly'],
      ),
      InAppPurchase(
        id: 'void_bundle_5k',
        name: 'VOID Bundle (5,000)',
        description: '5,000 VOID tokens',
        priceUSD: 9.99,
        priceType: 'USDT',
        benefits: ['5,000 VOID tokens'],
      ),
      InAppPurchase(
        id: 'void_bundle_20k',
        name: 'VOID Bundle (20,000)',
        description: '20,000 VOID tokens',
        priceUSD: 29.99,
        priceType: 'USDT',
        benefits: ['20,000 VOID tokens', '15% bonus'],
      ),
    ];
  }
  
  Future<void> setPaymentWalletAddress(String address) async {
    _paymentWalletAddress = address;
    await _savePurchases();
    notifyListeners();
  }
  
  Future<bool> processPurchase(String purchaseId, String transactionId) async {
    final purchase = _availablePurchases.firstWhere(
      (p) => p.id == purchaseId,
      orElse: () => InAppPurchase(
        id: '',
        name: '',
        description: '',
        priceUSD: 0,
        priceType: 'USD',
        benefits: [],
      ),
    );
    
    if (purchase.id.isEmpty) return false;
    
    // Record purchase
    final history = PurchaseHistory(
      id: transactionId,
      purchaseId: purchaseId,
      purchaseName: purchase.name,
      priceUSD: purchase.priceUSD,
      priceType: purchase.priceType,
      purchaseDate: DateTime.now(),
      status: 'completed',
    );
    
    _purchaseHistory.insert(0, history);
    await _savePurchases();
    
    // Apply purchase benefits
    await _applyPurchaseBenefits(purchase);
    
    notifyListeners();
    return true;
  }
  
  Future<void> _applyPurchaseBenefits(InAppPurchase purchase) async {
    // Apply benefits based on purchase type
    if (purchase.id.contains('void_bundle')) {
      final amount = purchase.id == 'void_bundle_5k' ? 5000.0 : 23000.0; // 15% bonus for 20k
      await _userService.updateUser(_userService.currentUser!.copyWith(
        balance: _userService.currentUser!.balance + amount,
      ));
    } else if (purchase.id.contains('energy_bundle')) {
      _energySystem.currentEnergy = min(
        _energySystem.currentEnergy + 100,
        _energySystem.maxEnergy + 100, // Allow exceeding max
      );
      await _saveEnergySystem();
    }
    // Other purchases would be tracked and applied by respective services
  }
  
  void _initializeDefaultFeatures() {
    if (_availableLootBoxes.isEmpty) {
      _initializeDefaultLootBoxes();
    }
    if (_availablePurchases.isEmpty) {
      _initializeDefaultPurchases();
    }
    
    // Create initial battle pass if none exists
    if (_currentBattlePass == null) {
      createSeasonalBattlePass(
        'Season 1: Genesis',
        DateTime.now().add(const Duration(days: 90)),
      );
    }
  }
}
