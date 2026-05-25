import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// クイズ終了時に表示するインタースティシャル広告を管理する。
/// クイズ開始時に load() を呼んで事前ロードし、
/// 終了時に showIfReady() で表示する。
class InterstitialAdService {
  InterstitialAd? _ad;
  bool _isReady = false;

  // TODO: 本番リリース時は AdMob コンソールで発行した実際のユニット ID に差し替えてください
  static String get _unitId => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/4411468910' // iOS テスト用
      : 'ca-app-pub-3940256099942544/1033173712'; // Android テスト用

  void load() {
    InterstitialAd.load(
      adUnitId: _unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isReady = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _isReady = false;
        },
      ),
    );
  }

  /// 広告が準備できていれば表示し、閉じられたら [onDismissed] を呼ぶ。
  /// ロード失敗時は広告をスキップして即座に [onDismissed] を呼ぶ。
  Future<void> showIfReady({VoidCallback? onDismissed}) async {
    if (!_isReady || _ad == null) {
      onDismissed?.call();
      return;
    }
    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        _isReady = false;
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('InterstitialAd failed to show: $error');
        ad.dispose();
        _ad = null;
        _isReady = false;
        onDismissed?.call();
      },
    );
    await _ad!.show();
  }

  void dispose() {
    _ad?.dispose();
  }
}
