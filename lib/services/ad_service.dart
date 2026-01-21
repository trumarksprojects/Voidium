import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService extends ChangeNotifier {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Test Ad Unit IDs (replace with real IDs in production)
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _rewardedAdUnitId1 = 'ca-app-pub-3940256099942544/5224354917';
  static const String _rewardedAdUnitId2 = 'ca-app-pub-3940256099942544/5224354917';

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd1;
  RewardedAd? _rewardedAd2;

  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAd1Loaded = false;
  bool _isRewardedAd2Loaded = false;

  DateTime? _rewardedAd1LastWatched;
  DateTime? _rewardedAd2LastWatched;

  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isRewardedAd1Available => _canWatchRewardedAd1();
  bool get isRewardedAd2Available => _canWatchRewardedAd2();

  Duration? get rewardedAd1Cooldown => _getCooldownRemaining(_rewardedAd1LastWatched);
  Duration? get rewardedAd2Cooldown => _getCooldownRemaining(_rewardedAd2LastWatched);

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await _loadLastWatchedTimes();
    loadBannerAd();
    loadInterstitialAd();
    loadRewardedAd1();
    loadRewardedAd2();
  }

  Future<void> _loadLastWatchedTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final ad1Time = prefs.getString('rewarded_ad_1_last_watched');
    final ad2Time = prefs.getString('rewarded_ad_2_last_watched');
    
    if (ad1Time != null) {
      _rewardedAd1LastWatched = DateTime.parse(ad1Time);
    }
    if (ad2Time != null) {
      _rewardedAd2LastWatched = DateTime.parse(ad2Time);
    }
  }

  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdLoaded = true;
          notifyListeners();
          if (kDebugMode) {
            debugPrint('Banner ad loaded');
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            debugPrint('Banner ad failed to load: $error');
          }
          ad.dispose();
          _isBannerAdLoaded = false;
          notifyListeners();
        },
      ),
    );
    _bannerAd!.load();
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          if (kDebugMode) {
            debugPrint('Interstitial ad loaded');
          }
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            debugPrint('Interstitial ad failed to load: $error');
          }
          _isInterstitialAdLoaded = false;
        },
      ),
    );
  }

  void loadRewardedAd1() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId1,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd1 = ad;
          _isRewardedAd1Loaded = true;
          notifyListeners();
          if (kDebugMode) {
            debugPrint('Rewarded ad 1 loaded');
          }
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            debugPrint('Rewarded ad 1 failed to load: $error');
          }
          _isRewardedAd1Loaded = false;
          notifyListeners();
        },
      ),
    );
  }

  void loadRewardedAd2() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId2,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd2 = ad;
          _isRewardedAd2Loaded = true;
          notifyListeners();
          if (kDebugMode) {
            debugPrint('Rewarded ad 2 loaded');
          }
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            debugPrint('Rewarded ad 2 failed to load: $error');
          }
          _isRewardedAd2Loaded = false;
          notifyListeners();
        },
      ),
    );
  }

  Future<void> showInterstitialAd() async {
    if (_interstitialAd != null && _isInterstitialAdLoaded) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadInterstitialAd(); // Load next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadInterstitialAd();
        },
      );
      await _interstitialAd!.show();
      _interstitialAd = null;
      _isInterstitialAdLoaded = false;
    }
  }

  bool _canWatchRewardedAd1() {
    if (_rewardedAd1LastWatched == null) return true;
    final timeDiff = DateTime.now().difference(_rewardedAd1LastWatched!);
    return timeDiff.inHours >= 1;
  }

  bool _canWatchRewardedAd2() {
    if (_rewardedAd2LastWatched == null) return true;
    final timeDiff = DateTime.now().difference(_rewardedAd2LastWatched!);
    return timeDiff.inHours >= 1;
  }

  Duration? _getCooldownRemaining(DateTime? lastWatched) {
    if (lastWatched == null) return null;
    final timeDiff = DateTime.now().difference(lastWatched);
    if (timeDiff.inHours >= 1) return null;
    return const Duration(hours: 1) - timeDiff;
  }

  Future<double?> showRewardedAd1() async {
    if (!_canWatchRewardedAd1()) return null;
    if (_rewardedAd1 == null || !_isRewardedAd1Loaded) return null;

    double? rewardAmount;
    
    _rewardedAd1!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardedAd1(); // Load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadRewardedAd1();
      },
    );

    await _rewardedAd1!.show(
      onUserEarnedReward: (ad, reward) async {
        rewardAmount = 100.0; // Reward amount for ad 1
        _rewardedAd1LastWatched = DateTime.now();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('rewarded_ad_1_last_watched', _rewardedAd1LastWatched!.toIso8601String());
        notifyListeners();
      },
    );

    _rewardedAd1 = null;
    _isRewardedAd1Loaded = false;
    return rewardAmount;
  }

  Future<double?> showRewardedAd2() async {
    if (!_canWatchRewardedAd2()) return null;
    if (_rewardedAd2 == null || !_isRewardedAd2Loaded) return null;

    double? rewardAmount;
    
    _rewardedAd2!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardedAd2(); // Load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadRewardedAd2();
      },
    );

    await _rewardedAd2!.show(
      onUserEarnedReward: (ad, reward) async {
        rewardAmount = 150.0; // Reward amount for ad 2
        _rewardedAd2LastWatched = DateTime.now();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('rewarded_ad_2_last_watched', _rewardedAd2LastWatched!.toIso8601String());
        notifyListeners();
      },
    );

    _rewardedAd2 = null;
    _isRewardedAd2Loaded = false;
    return rewardAmount;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd1?.dispose();
    _rewardedAd2?.dispose();
    super.dispose();
  }
}
