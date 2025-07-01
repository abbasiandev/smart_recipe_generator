import 'package:flutter/foundation.dart';

class ErrorHandler {
  static void handleError(dynamic error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('Error: $error');
      print('Stack Trace: $stackTrace');
    }
  }

  static String getUserFriendlyMessage(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'Please check your internet connection and try again.';
    } else if (error.toString().contains('401')) {
      return 'Authentication failed. Please check your API key.';
    } else if (error.toString().contains('429')) {
      return 'Too many requests. Please wait a moment and try again.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else {
      return 'Something went wrong. Please try again later.';
    }
  }
}