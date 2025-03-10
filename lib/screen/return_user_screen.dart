import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

class ReturnUserScreen extends StatefulWidget {
  const ReturnUserScreen({super.key});

  @override
  _ReturnUserScreenState createState() => _ReturnUserScreenState();
}

class _ReturnUserScreenState extends State<ReturnUserScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );
    
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final bool isPermanent = prefs.getBool('isPermanentLogin') ?? false;
      
      if (!mounted) return;

      if (isLoggedIn) {
        if (isPermanent) {
          Navigator.pushReplacementNamed(context, '/map');
        } else {
          final int? loginTimestamp = prefs.getInt('loginTimestamp');
          if (loginTimestamp != null) {
            final DateTime loginTime = DateTime.fromMillisecondsSinceEpoch(loginTimestamp);
            final Duration difference = DateTime.now().difference(loginTime);
            
            if (difference.inHours < 24) {
              Navigator.pushReplacementNamed(context, '/map');
            } else {
              Navigator.pushReplacementNamed(context, '/login');
            }
          }
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Image.asset(
                      "assets/aislogo.png",
                      width: 150,
                      height: 150,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            
            // Custom animated loading indicator
            SizedBox(
              width: 60,
              height: 60,
              child: CustomPaint(
                painter: LoadingPainter(
                  animation: _animationController,
                  color: const Color(0xff3a57e8),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Animated welcome text
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff3a57e8),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 15),
            
            // Loading text
            Text(
              "Preparing your data...",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xff3a57e8).withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom loading indicator painter
class LoadingPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  
  LoadingPainter({required this.animation, required this.color}) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - paint.strokeWidth / 2;
    
    // Draw background circle
    paint.color = color.withOpacity(0.2);
    canvas.drawCircle(center, radius, paint);
    
    // Draw animated arc
    paint.color = color;
    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * animation.value;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
    
    // Draw small circles at the end of the arc
    final endAngle = startAngle + sweepAngle;
    final endPoint = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );
    
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(endPoint, paint.strokeWidth, paint);
  }
  
  @override
  bool shouldRepaint(LoadingPainter oldDelegate) => true;
}