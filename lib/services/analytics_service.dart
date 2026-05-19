import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import '../utils/ml_confidence.dart';

/// Centralized Firebase Analytics event logging.
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> _log(String name, [Map<String, Object>? parameters]) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      debugPrint('[Analytics] $name ${parameters ?? ''}');
    } catch (e) {
      debugPrint('[Analytics] failed $name: $e');
    }
  }

  Future<void> logAnalyticsScreenOpened() =>
      _log('analytics_screen_opened');

  Future<void> logScanStarted() => _log('scan_started');

  Future<void> logHistoryOpened() => _log('history_opened');

  Future<void> logDiseaseDetailsOpened({
    required String diseaseName,
    required String crop,
  }) =>
      _log('disease_details_opened', {
        'disease_name': diseaseName,
        'crop': crop,
      });

  Future<void> logDiseaseDetected({
    required String diseaseName,
    required String crop,
    required double confidence,
  }) =>
      _log('disease_detected', {
        'disease_name': diseaseName,
        'crop': crop,
        'confidence': confidence,
        'confidence_level': MlConfidence.levelFor(confidence).label,
      });

  Future<void> logLowConfidenceScan({
    required String diseaseName,
    required String crop,
    required double confidence,
  }) =>
      _log('low_confidence_scan', {
        'disease_name': diseaseName,
        'crop': crop,
        'confidence': confidence,
        'confidence_level': 'Low',
      });

  Future<void> logNoLeafDetected() => _log('no_leaf_detected');

  Future<void> logLogin() async {
    try {
      await _analytics.logLogin(loginMethod: 'email');
    } catch (e) {
      debugPrint('[Analytics] logLogin failed: $e');
    }
  }

  Future<void> logSignUp() async {
    try {
      await _analytics.logSignUp(signUpMethod: 'email');
    } catch (e) {
      debugPrint('[Analytics] logSignUp failed: $e');
    }
  }

  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      debugPrint('[Analytics] logScreenView failed: $e');
    }
  }
}
