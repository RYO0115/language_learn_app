import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../features/settings/presentation/settings_provider.dart';

const kFreeWordLimit = 1000;
const kPremiumProductId = 'language_learn_app_premium';

class PurchaseState {
  const PurchaseState({
    this.isAvailable = false,
    this.productDetails,
    this.isPending = false,
    this.errorMessage,
  });

  final bool isAvailable;
  final ProductDetails? productDetails;
  final bool isPending;
  final String? errorMessage;
}

final purchaseProvider =
    StateNotifierProvider<PurchaseNotifier, PurchaseState>(
  (ref) => PurchaseNotifier(ref),
);

class PurchaseNotifier extends StateNotifier<PurchaseState> {
  PurchaseNotifier(this._ref) : super(const PurchaseState()) {
    _init();
  }

  final Ref _ref;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Future<void> _init() async {
    final iap = InAppPurchase.instance;
    final available = await iap.isAvailable();
    if (!available) return;

    _subscription = iap.purchaseStream.listen(_onPurchaseUpdate);

    final response = await iap.queryProductDetails({kPremiumProductId});
    final product = response.productDetails.isNotEmpty
        ? response.productDetails.first
        : null;

    if (mounted) {
      state = PurchaseState(isAvailable: true, productDetails: product);
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID != kPremiumProductId) continue;

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _ref.read(settingsProvider.notifier).setPremium(true);
        if (mounted) {
          state = PurchaseState(
            isAvailable: state.isAvailable,
            productDetails: state.productDetails,
          );
        }
        if (purchase.pendingCompletePurchase) {
          InAppPurchase.instance.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.error) {
        if (mounted) {
          state = PurchaseState(
            isAvailable: state.isAvailable,
            productDetails: state.productDetails,
            errorMessage: purchase.error?.message,
          );
        }
        if (purchase.pendingCompletePurchase) {
          InAppPurchase.instance.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.pending) {
        if (mounted) {
          state = PurchaseState(
            isAvailable: state.isAvailable,
            productDetails: state.productDetails,
            isPending: true,
          );
        }
      }
    }
  }

  Future<void> buy() async {
    final product = state.productDetails;
    if (product == null) return;
    await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  Future<void> restore() async {
    if (mounted) {
      state = PurchaseState(
        isAvailable: state.isAvailable,
        productDetails: state.productDetails,
        isPending: true,
      );
    }
    await InAppPurchase.instance.restorePurchases();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
