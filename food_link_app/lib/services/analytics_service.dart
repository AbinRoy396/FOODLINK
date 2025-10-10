import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Log donation created event
  static Future<void> logDonationCreated({
    required String foodType,
    required String quantity,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'donation_created',
        parameters: {
          'food_type': foodType,
          'quantity': quantity,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log donation deleted event
  static Future<void> logDonationDeleted(String donationId) async {
    try {
      await _analytics.logEvent(
        name: 'donation_deleted',
        parameters: {'donation_id': donationId},
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log donation shared event
  static Future<void> logDonationShared(String donationId) async {
    try {
      await _analytics.logEvent(
        name: 'donation_shared',
        parameters: {'donation_id': donationId},
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log chat opened event
  static Future<void> logChatOpened(String otherUserId) async {
    try {
      await _analytics.logEvent(
        name: 'chat_opened',
        parameters: {'other_user_id': otherUserId},
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log screen view
  static Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log search performed
  static Future<void> logSearch(String searchTerm) async {
    try {
      await _analytics.logSearch(searchTerm: searchTerm);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log user login
  static Future<void> logLogin(String method) async {
    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log user signup
  static Future<void> logSignUp(String method) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }
}
