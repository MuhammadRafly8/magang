import 'package:flutter/material.dart';
import 'log_utils.dart';

class ErrorHandler {
  static bool _isDialogShowing = false;
  static bool _isSnackBarShowing = false;
  static const Duration _snackBarDuration = Duration(seconds: 3);

  static Future<void> showErrorDialog(BuildContext context, String message) async {
    if (_isDialogShowing || !context.mounted) return;
    _isDialogShowing = true;
    
    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                _isDialogShowing = false;
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      _isDialogShowing = false;
      LogUtils.error('Error showing dialog', e);
    }
  }

  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    if (_isSnackBarShowing || !context.mounted) return;
    _isSnackBarShowing = true;

    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.clearSnackBars();
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: _snackBarDuration,
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onVisible: () {
            Future.delayed(_snackBarDuration, () {
              _isSnackBarShowing = false;
            });
          },
        ),
      );
    } catch (e) {
      _isSnackBarShowing = false;
      LogUtils.error('Error showing snackbar', e);
    }
  }
}