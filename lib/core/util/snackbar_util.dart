import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../constant/constants.dart';

class SnackbarUtil {
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      Colors.green,
      Icons.check_circle,
    );
  }

  static void showError(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      Colors.red,
      Icons.error,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      Colors.orange,
      Icons.warning,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      Colors.blue,
      Icons.info,
    );
  }

  static void _showSnackbar(
      BuildContext context,
      String message,
      Color backgroundColor,
      IconData icon,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: AutoSizeText(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(AppConstants.paddingMedium),
      ),
    );
  }
}