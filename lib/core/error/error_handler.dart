import 'package:flutter/foundation.dart';

class ErrorHandler {
  static void handleError(dynamic error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('Error: $error');
      print('Stack Trace: $stackTrace');
    }
  }

  static String getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socketexception') || errorString.contains('no internet')) {
      return 'Please check your internet connection and try again.';
    } else if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Authentication failed. Please check your API key.';
    } else if (errorString.contains('429') || errorString.contains('rate limit')) {
      return 'Too many requests. Please wait a moment and try again.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('400') || errorString.contains('bad request')) {
      return 'Invalid request. Please check your input and try again.';
    } else if (errorString.contains('500') || errorString.contains('server error')) {
      return 'Server error. Please try again later.';
    } else if (errorString.contains('api key not found')) {
      return 'OpenAI API key is missing. Please add it to your .env file.';
    } else if (errorString.contains('formatexception') || errorString.contains('invalid response')) {
      return 'Received invalid response. Please try again.';
    } else {
      return 'Something went wrong. Please try again later.';
    }
  }
}