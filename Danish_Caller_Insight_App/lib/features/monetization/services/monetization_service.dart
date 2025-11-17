import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/logger.dart';

/// Service handling monetization features
class MonetizationService extends StateNotifier<MonetizationState> {
  MonetizationService() : super(MonetizationState.initial()) {
    _initialize();
  }
  
  static const String _premiumProductId = 'premium_monthly';
  static const int _freeLookupLimit = 5;
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late final SharedPreferences _prefs;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  int _interstitialLoadAttempts = 0;
  static const int _maxInterstitialLoadAttempts = 3;
  
  /// Initialize monetization service
  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Initialize in-app purchases
    await _initializeInAppPurchases();
    
    // Initialize ads
    await _initializeAds();
    
    // Load user state
    await _loadUserState();
  }
  
  /// Initialize in-app purchases
  Future<void> _initializeInAppPurchases() async {
    final available = await _inAppPurchase.isAvailable();
    if (!available) {
      Logger.error('In-app purchases not available');
      state = state.copyWith(isPremiumAvailable: false);
      return;
    }
    
    // Listen to purchase updates
    _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdate,
      onError: _handlePurchaseError,
    );
    
    // Query products
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(
      {_premiumProductId},
    );
    
    if (response.productDetails.isNotEmpty) {
      state = state.copyWith(
        premiumProduct: response.productDetails.first,
        isPremiumAvailable: true,
      );
    } else {
      Logger.error('Premium product not found: ${response.error}');
      state = state.copyWith(isPremiumAvailable: false);
    }
  }
  
  /// Initialize ads
  Future<void> _initializeAds() async {
    try {
      await MobileAds.instance.initialize();
      
      // Request consent information
      final consentInfo = await ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
      );
      
      if (consentInfo.formStatus == FormStatus.available) {
        await ConsentForm.loadAndShowConsentFormIfRequired();
      }
      
      // Load banner ad
      await _loadBannerAd();
      
      // Preload interstitial ad
      await _loadInterstitialAd();
      
    } catch (e) {
      Logger.error('Failed to initialize ads', e);
    }
  }
  
  /// Load banner ad
  Future<void> _loadBannerAd() async {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          Logger.info('Banner ad loaded');
          state = state.copyWith(isBannerAdLoaded: true);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          Logger.error('Banner ad failed to load', error);
          ad.dispose();
          _bannerAd = null;
        },
      ),
    );
    
    await _bannerAd?.load();
  }
  
  /// Load interstitial ad
  Future<void> _loadInterstitialAd() async {
    try {
      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            Logger.info('Interstitial ad loaded');
            _interstitialAd = ad;
            _interstitialLoadAttempts = 0;
            
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (Ad ad) {
                ad.dispose();
                _loadInterstitialAd(); // Preload next ad
              },
              onAdFailedToShowFullScreenContent: (Ad ad, AdError error) {
                ad.dispose();
                _loadInterstitialAd(); // Try to load another ad
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            Logger.error('Interstitial ad failed to load', error);
            _interstitialLoadAttempts++;
            
            if (_interstitialLoadAttempts < _maxInterstitialLoadAttempts) {
              // Retry after delay
              Future.delayed(Duration(seconds: 10), _loadInterstitialAd);
            }
          },
        ),
      );
    } catch (e) {
      Logger.error('Failed to load interstitial ad', e);
    }
  }
  
  /// Load user state from preferences
  Future<void> _loadUserState() async {
    final isPremium = _prefs.getBool('is_premium') ?? false;
    final lookupCount = _prefs.getInt('lookup_count') ?? 0;
    final lastResetDate = _prefs.getString('last_reset_date');
    
    // Reset daily count if it's a new day
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastResetDate != today) {
      await _prefs.setInt('lookup_count', 0);
      await _prefs.setString('last_reset_date', today);
    }
    
    state = state.copyWith(
      isPremium: isPremium,
      dailyLookupCount: lookupCount,
      lastResetDate: lastResetDate ?? today,
    );
  }
  
  /// Handle purchase updates
  void _handlePurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          state = state.copyWith(purchasePending: true);
          break;
          
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _verifyPurchase(purchase);
          break;
          
        case PurchaseStatus.error:
          state = state.copyWith(
            purchasePending: false,
            purchaseError: purchase.error?.message,
          );
          break;
          
        case PurchaseStatus.canceled:
          state = state.copyWith(purchasePending: false);
          break;
      }
    }
  }
  
  /// Handle purchase errors
  void _handlePurchaseError(dynamic error) {
    Logger.error('Purchase error', error);
    state = state.copyWith(
      purchasePending: false,
      purchaseError: error.toString(),
    );
  }
  
  /// Verify purchase
  Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    // In a real app, you would verify the purchase with your backend
    // For now, we'll trust the purchase and activate premium
    
    if (purchase.productID == _premiumProductId) {
      await _activatePremium();
      await _inAppPurchase.completePurchase(purchase);
    }
  }
  
  /// Activate premium features
  Future<void> _activatePremium() async {
    await _prefs.setBool('is_premium', true);
    state = state.copyWith(
      isPremium: true,
      purchasePending: false,
      purchaseError: null,
    );
    
    Logger.info('Premium features activated');
  }
  
  /// Purchase premium subscription
  Future<void> purchasePremium() async {
    if (state.premiumProduct == null) {
      Logger.error('Premium product not available');
      return;
    }
    
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: state.premiumProduct!,
    );
    
    await _inAppPurchase.buyNonConsumable(
      purchaseParam: purchaseParam,
    );
  }
  
  /// Restore purchases
  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }
  
  /// Check if user can perform lookup (within free limit or premium)
  bool canPerformLookup() {
    if (state.isPremium) return true;
    return state.dailyLookupCount < _freeLookupLimit;
  }
  
  /// Record lookup attempt
  Future<void> recordLookup() async {
    if (state.isPremium) return;
    
    final newCount = state.dailyLookupCount + 1;
    await _prefs.setInt('lookup_count', newCount);
    state = state.copyWith(dailyLookupCount: newCount);
    
    // Show interstitial ad every 5 lookups
    if (newCount % 5 == 0 && _interstitialAd != null) {
      await _showInterstitialAd();
    }
  }
  
  /// Show interstitial ad
  Future<void> _showInterstitialAd() async {
    if (_interstitialAd != null) {
      await _interstitialAd!.show();
      _interstitialAd = null;
    }
  }
  
  /// Get banner ad widget
  Widget? getBannerAdWidget() {
    if (_bannerAd == null || state.isPremium) return null;
    
    return Container(
      height: 50,
      child: AdWidget(ad: _bannerAd!),
    );
  }
  
  /// Get remaining lookups for free users
  int getRemainingLookups() {
    if (state.isPremium) return -1; // Unlimited
    return _freeLookupLimit - state.dailyLookupCount;
  }
  
  /// Get lookup limit
  int get lookupLimit => _freeLookupLimit;
  
  /// Dispose resources
  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }
}

/// State for monetization
class MonetizationState {
  final bool isPremium;
  final bool isPremiumAvailable;
  final ProductDetails? premiumProduct;
  final bool purchasePending;
  final String? purchaseError;
  final int dailyLookupCount;
  final String lastResetDate;
  final bool isBannerAdLoaded;
  
  const MonetizationState({
    required this.isPremium,
    required this.isPremiumAvailable,
    this.premiumProduct,
    required this.purchasePending,
    this.purchaseError,
    required this.dailyLookupCount,
    required this.lastResetDate,
    required this.isBannerAdLoaded,
  });
  
  factory MonetizationState.initial() {
    return const MonetizationState(
      isPremium: false,
      isPremiumAvailable: true,
      premiumProduct: null,
      purchasePending: false,
      purchaseError: null,
      dailyLookupCount: 0,
      lastResetDate: '',
      isBannerAdLoaded: false,
    );
  }
  
  MonetizationState copyWith({
    bool? isPremium,
    bool? isPremiumAvailable,
    ProductDetails? premiumProduct,
    bool? purchasePending,
    String? purchaseError,
    int? dailyLookupCount,
    String? lastResetDate,
    bool? isBannerAdLoaded,
  }) {
    return MonetizationState(
      isPremium: isPremium ?? this.isPremium,
      isPremiumAvailable: isPremiumAvailable ?? this.isPremiumAvailable,
      premiumProduct: premiumProduct ?? this.premiumProduct,
      purchasePending: purchasePending ?? this.purchasePending,
      purchaseError: purchaseError ?? this.purchaseError,
      dailyLookupCount: dailyLookupCount ?? this.dailyLookupCount,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      isBannerAdLoaded: isBannerAdLoaded ?? this.isBannerAdLoaded,
    );
  }
}

/// Provider for monetization service
final monetizationServiceProvider = StateNotifierProvider<MonetizationService, MonetizationState>(
  (ref) => MonetizationService(),
);