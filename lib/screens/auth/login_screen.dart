import 'package:flutter/material.dart';
import 'package:multi_user/screens/auth/complete_profile_screen.dart';
import '../../main.dart';
import 'signup_screen.dart';
import '../../services/auth_service.dart';
import '../../utils/showFlushbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // First login to get token
        await _authService.login(
          _emailController.text,
          _passwordController.text,
        );
        
        // Then get complete user data including doctor/patient profiles
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
        if (!mounted) return;
        showFlushBar(context, message: 'Failed to login', success: false);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading 
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  );
                },
                child: const Text('Don\'t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
