import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../main.dart';
import 'auth/login_screen.dart';
import 'auth/complete_profile_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthAndProfile();
  }

  Future<void> _checkAuthAndProfile() async {
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated) {
        _navigateToLogin();
        return;
      }

      final user = await _authService.getCompleteUserData();
      
      if (!mounted) return;

      if ((user.roleType == 'DOCTOR' && user.doctor == null) ||
          (user.roleType == 'PATIENT' && user.patient == null)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CompleteProfileScreen(
              userId: user.id,
              roleType: user.roleType,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      }
    } catch (e) {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
