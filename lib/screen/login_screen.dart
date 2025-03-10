import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp1());
}

class MyApp1 extends StatelessWidget {
  const MyApp1({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;  // Tambahkan variabel loading state
  // Data login yang valid
  final String validUsername = "user@rams.co.id";
  final String validPassword = "userRams200!!";
  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _checkLoginStatus();
  }
  // Fungsi untuk memeriksa status login
  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final bool isPermanent = prefs.getBool('isPermanentLogin') ?? false;
      
      if (isLoggedIn) {
        if (isPermanent) {
          // Login permanen (Remember Me)
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/map');
          }
        } else {
          // Login sementara (24 jam)
          final int? loginTimestamp = prefs.getInt('loginTimestamp');
          if (loginTimestamp != null) {
            final DateTime loginTime = DateTime.fromMillisecondsSinceEpoch(loginTimestamp);
            final DateTime now = DateTime.now();
            final Duration difference = now.difference(loginTime);
            
            // Cek apakah masih dalam 24 jam
            if (difference.inHours < 24) {
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/map');
              }
            } else {
              // Hapus status login jika sudah lebih dari 24 jam
              await prefs.setBool('isLoggedIn', false);
            }
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking login status: $e')),
      );
    }
  }
  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      
      setState(() {
        _emailController.text = prefs.getString('email') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
        _rememberMe = prefs.getBool('rememberMe') ?? false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading saved credentials: $e')),
      );
    }
  }
  Future<void> _saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Simpan status login
      await prefs.setBool('isLoggedIn', true);
      await prefs.setBool('isPermanentLogin', _rememberMe);
      await prefs.setInt('loginTimestamp', DateTime.now().millisecondsSinceEpoch);
      
      if (_rememberMe) {
        await prefs.setString('email', _emailController.text);
        await prefs.setString('password', _passwordController.text);
        await prefs.setBool('rememberMe', true);
      } else {
        await prefs.remove('email');
        await prefs.remove('password');
        await prefs.setBool('rememberMe', false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving credentials: $e')),
      );
    }
  }
  Future<void> _login() async {
    setState(() {
      _isLoading = true;  // Aktifkan loading state
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      // Tambahkan delay kecil untuk simulasi loading data kapal
      await Future.delayed(const Duration(seconds: 2));
      
      if (email == validUsername && password == validPassword) {
        await _saveCredentials();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/map');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid username or password!"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;  // Nonaktifkan loading state
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xffe6e6e6),
      body: Stack(
        children: <Widget>[
          Container(
            width: screenWidth,
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: const BoxDecoration(
              color: Color(0xff3a57e8),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(40, 100, 40, 20), // Padding kanan-kiri lebih dalam
            decoration: BoxDecoration(
              color: const Color(0xffffffff),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20), // Padding lebih rapi
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    // Logo dengan ukuran yang sama dan responsif
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Image.asset(
                            "assets/logo pertamina 1.png",
                            fit: BoxFit.contain,
                            height: 80,
                          ),
                        ),
                        const SizedBox(width: 20), // Jarak seimbang antara logo
                        Expanded(
                          child: Image.asset(
                            "assets/aislogo.png",
                            fit: BoxFit.contain,
                            height: 80,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Teks Login di tengah
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Login",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          color: Color(0xff000000),
                        ),
                      ),
                    ),

                    // Input Email dengan padding lebih dalam
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20), // Padding lebih dalam
                          hintText: "Enter Email",
                          hintStyle: const TextStyle(fontSize: 14, color: Color(0xff494646)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xff000000), width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xff000000), width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    // Input Password TextField
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        hintText: "Enter Password",
                        hintStyle: const TextStyle(fontSize: 14, color: Color(0xff494646)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xff000000), width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xff000000), width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Remember Me checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: const Color(0xff3a57e8),
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        ),
                        const Text(
                          'Remember Me',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff494646),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: MaterialButton(
                        onPressed: _isLoading ? null : _login,
                        color: const Color(0xff3a57e8),
                        disabledColor: const Color(0xff3a57e8).withOpacity(0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(16),
                        textColor: const Color(0xffffffff),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
                            : const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    // Daftar Akun
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Don't have an account?",
                            style: TextStyle(fontSize: 14, color: Color(0xff000000)),
                          ),
                          SizedBox(width: 4),
                          Text(
                            "SignUp",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Color(0xff000000),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
