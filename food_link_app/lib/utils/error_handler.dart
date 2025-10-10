import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/app_colors.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ErrorHandler {
  /// Show user-friendly error message
  static void showError(BuildContext context, dynamic error) {
    String message = _getUserFriendlyMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
    
    // Log to Crashlytics (disabled - enable after Firebase setup)
    // FirebaseCrashlytics.instance.recordError(
    //   error,
    //   StackTrace.current,
    //   reason: 'User-facing error',
    // );
  }

  /// Show success message
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show info message
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show warning message
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_outlined, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Convert technical errors to user-friendly messages
  static String _getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please check your internet connection.';
    }
    
    if (errorString.contains('socket') || errorString.contains('network')) {
      return 'Network error. Please check your internet connection.';
    }
    
    if (errorString.contains('session expired') || errorString.contains('401')) {
      return 'Your session has expired. Please login again.';
    }
    
    if (errorString.contains('server error') || errorString.contains('500')) {
      return 'Server error. Please try again later.';
    }
    
    if (errorString.contains('not found') || errorString.contains('404')) {
      return 'Resource not found. Please try again.';
    }
    
    if (errorString.contains('permission')) {
      return 'Permission denied. Please check app permissions.';
    }
    
    if (errorString.contains('storage')) {
      return 'Storage error. Please check available space.';
    }
    
    if (errorString.contains('firebase')) {
      return 'Service temporarily unavailable. Please try again.';
    }
    
    // Default message
    return 'Something went wrong. Please try again.';
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message ?? 'Please wait...'),
            ],
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDangerous
                ? ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                  )
                : ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                  ),
            child: Text(confirmText, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  /// Log error to Crashlytics (disabled - enable after Firebase setup)
  static void logError(dynamic error, StackTrace? stackTrace, {String? reason}) {
    // FirebaseCrashlytics.instance.recordError(
    //   error,
    //   stackTrace ?? StackTrace.current,
    //   reason: reason,
    // );
  }

  /// Log custom message to Crashlytics (disabled - enable after Firebase setup)
  static void logMessage(String message) {
    // FirebaseCrashlytics.instance.log(message);
  }
}
