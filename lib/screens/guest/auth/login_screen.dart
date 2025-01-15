import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isFormVisible = false;
  bool _isPasswordVisible = false;

  // API URL Constants
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  static const String loginEndpoint = '$baseUrl/users/login';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    checkExistingToken();
  }

  Future<void> checkExistingToken() async {
    final token = await storage.read(key: 'access_token');
    if (token != null) {
      // Token exists, navigate to home
      if (mounted) context.go('/home');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() {
      _isFormVisible = !_isFormVisible;
      if (_isFormVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _showAlert(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await storage.write(key: 'access_token', value: accessToken);
    await storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> _login() async {
    final identifier = identifierController.text.trim();
    final password = passwordController.text.trim();

    // Validasi input
    if (identifier.isEmpty || password.isEmpty) {
      _showAlert(
        'Validation Error',
        'Please enter your email/username and password.',
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'identifier': identifier,
          'password': password,
        }),
      );

      // Parse response
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Login successful
        if (responseData['status'] == 'success') {
          // Save tokens
          await _saveTokens(
            responseData['data']['access_token'],
            responseData['data']['refresh_token'],
          );
          
          if (mounted) {
            // Show success message before navigation
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseData['message'] ?? 'Login successful'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Navigate to home
            context.go('/home');
          }
        } else {
          throw Exception(responseData['message'] ?? 'Login failed');
        }
      } else if (response.statusCode == 401) {
        _showAlert(
          'Authentication Failed',
          'Invalid email/username or password.',
        );
      } else if (response.statusCode == 422) {
        _showAlert(
          'Validation Error',
          responseData['message'] ?? 'Please check your input.',
        );
      } else {
        _showAlert(
          'Login Failed',
          responseData['message'] ?? 'An error occurred during login.',
        );
      }
    } catch (e) {
      _showAlert(
        'Error',
        'Failed to connect to the server. Please check your internet connection.',
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/waves.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 60),
                                Image.asset(
                                  'assets/images/iconic_screen_logo.png',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!_isFormVisible) ...[
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        const Text(
                          'Catat Pelangganmu!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Kelola pelanggan dengan mudah, catat data, dan tingkatkan bisnismu sekarang juga!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                            onPressed: _toggleForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E88E5),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: const Text(
                            "Don't have an account?",
                            style: TextStyle(color: Color(0xFF1E88E5)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'v1.0.0',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_isFormVisible)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleForm,
                child: Container(color: Colors.black54),
              ),
            ),
          if (_isFormVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: _toggleForm,
                          ),
                          const Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: identifierController,
                        decoration: const InputDecoration(
                          labelText: 'Email or Username',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible,
                            ),
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                      ),
                      const SizedBox(height: 24),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E88E5),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.go('/forgot-password'),
                        child: const Text(
                          'Forgot Email/Password?',
                          style: TextStyle(color: Color(0xFF1E88E5)),
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