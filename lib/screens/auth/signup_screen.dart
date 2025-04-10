import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/showFlushbar.dart';
import 'complete_profile_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String _selectedRole = 'PATIENT';
  static const List<String> _roles = ['PATIENT', 'DOCTOR'];

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final userData = await _authService.register(
          _emailController.text,
          _passwordController.text,
          _firstnameController.text,
          _lastnameController.text,
          '', // phone is no longer collected here
          _selectedRole,
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CompleteProfileScreen(
              userId: userData['user']['id'],
              roleType: _selectedRole,
            ),
          ),
        );
      } catch (e) {
        showFlushBar(context, message: 'Failed to register', success: false);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstnameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastnameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: _roles.map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (value) => setState(() => _selectedRole = value!),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                child: _isLoading 
                    ? const CircularProgressIndicator()
                    : const Text('Sign Up'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
