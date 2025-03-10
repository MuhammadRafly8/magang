import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // Setup animasi
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _controller.forward();
    
    // Navigasi setelah animasi splash
    Timer(const Duration(seconds: 3), () {
      _checkLoginStatus();
    });
  }
  
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (!mounted) return;
    
    if (isLoggedIn) {
      // Jika user sudah login, arahkan ke ReturnUserScreen
      Navigator.pushReplacementNamed(context, '/return_user');
    } else {
      // Jika belum login, arahkan ke LoginScreen
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/aislogo.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 30),
              const Text(
                'Early Warning System',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff3a57e8),
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                color: Color(0xff3a57e8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}