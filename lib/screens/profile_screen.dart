import 'package:flutter/material.dart';
import '../models/user.dart';
import 'auth/login_screen.dart';
import '../../services/auth_service.dart';
import '../utils/showFlushbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isEditing = false;
  User? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getCurrentUser();
      setState(() {
        _userData = userData;
        _firstnameController.text = userData.firstname;
        _lastnameController.text = userData.lastname;
        _phoneController.text = userData.phone ?? '';
        _emailController.text = userData.email;
      });
    } catch (e) {
      if (mounted) {
        showFlushBar(context, message: 'Failed to load profile data', success: false);
      }
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final updatedUser = await _authService.updateProfile({
          'firstname': _firstnameController.text,
          'lastname': _lastnameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
        });
        setState(() {
          _isEditing = false;
          _userData = updatedUser;
        });
        showFlushBar(context, message: 'Profile updated successfully', success: true);
      } catch (e) {
        if (mounted) {
          showFlushBar(context, message: 'Failed to update profile', success: false);
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _handleRefresh() async {
    try {
      final userData = await _authService.getCurrentUser();
      setState(() {
        _userData = userData;
        _firstnameController.text = userData.firstname;
        _lastnameController.text = userData.lastname;
        _phoneController.text = userData.phone ?? '';
        _emailController.text = userData.email;
      });
    } catch (e) {
      if (mounted) {
        showFlushBar(context, message: 'Failed to refresh profile', success: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profileeeeee'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _userData == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.person, size: 50),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _firstnameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            fillColor: Colors.transparent,
                          ),
                          enabled: _isEditing,
                          style: const TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _lastnameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            fillColor: Colors.transparent,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your last name';
                            }
                            return null;
                          },
                          enabled: _isEditing,
                          style: const TextStyle(color: Colors.black),
                        ),
                        if (_isEditing) const SizedBox(height: 24),
                        if (_isEditing)
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleSave,
                            child: const Text('Save Changes'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
