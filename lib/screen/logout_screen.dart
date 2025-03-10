import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushReplacementNamed(context, '/map'); // Back to map
              },
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () async {
                // Hapus status login
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);
                
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushReplacementNamed(context, '/login'); // Go to login
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show logout dialog as soon as screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLogoutDialog(context);
    });

    // Return empty scaffold while dialog is showing
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}