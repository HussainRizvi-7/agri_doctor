import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logScanPerformed(String diseaseName, String severity) async {
    await _analytics.logEvent(
      name: 'scan_performed',
      parameters: {
        'disease_name': diseaseName,
        'severity': severity,
      },
    );
  }

  Future<void> logLogin() async {
    await _analytics.logLogin(loginMethod: 'email');
  }

  Future<void> logSignUp() async {
    await _analytics.logSignUp(signUpMethod: 'email');
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}
