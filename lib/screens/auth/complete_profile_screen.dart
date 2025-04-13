import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../main.dart';
import '../../utils/showFlushbar.dart';
import 'login_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  final int userId;
  final String roleType;

  const CompleteProfileScreen({
    super.key,
    required this.userId,
    required this.roleType,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _specialityController = TextEditingController();
  final _authService = AuthService();
  DateTime? _birthdate;
  bool _isLoading = false;

  Future<void> _handleComplete() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (widget.roleType == 'DOCTOR') {
        await _authService.createDoctorProfile(
          userId: widget.userId,
          speciality: _specialityController.text,
        );
      } else {
        if (_birthdate == null) {
          showFlushBar(
            context,
            message: 'Please select birthdate',
            success: false,
          );
          setState(() => _isLoading = false);
          return;
        }
        await _authService.createPatientProfile(
          userId: widget.userId,
          birthdate: _birthdate!,
        );
      }

      showFlushBar(
        context,
        message: 'Profile completed successfully',
        success: true,
      );

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    } catch (e) {
      showFlushBar(
        context,
        message: e.toString().replaceAll('Exception: ', ''),
        success: false,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.roleType == 'DOCTOR')
                TextFormField(
                  controller: _specialityController,
                  decoration: const InputDecoration(labelText: 'Speciality'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                )
              else
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _birthdate = date);
                    }
                  },
                  child: Text(_birthdate == null 
                    ? 'Select Birthdate'
                    : 'Birthdate: ${_birthdate.toString().split(' ')[0]}'),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleComplete,
                child: _isLoading 
                    ? const CircularProgressIndicator()
                    : const Text('Complete Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
