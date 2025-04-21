import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'doctor_offices_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final _authService = AuthService();
  String? doctorId;

  @override
  void initState() {
    super.initState();
    _loadDoctorId();
  }

  Future<void> _loadDoctorId() async {
    try {
      final user = await _authService.getCompleteUserData();
      print('Complete user data: ${user.doctor}'); // Debug print
      if (mounted) {
        setState(() {
          // Use documentId instead of id
          doctorId = user.doctor?['documentId']?.toString();
        });
      }
    } catch (e) {
      print('Error loading doctor ID: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading doctor profile')),
        );
      }
    }
  }

  void _navigateToOffices() {
    if (doctorId == null) return;

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => DoctorOfficesScreen(doctorId: doctorId!),
      ),
    )
        .then((_) {
      // Refresh data when returning from offices screen
      _loadDoctorId();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
      ),
      body: doctorId == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.medical_services),
                    title: const Text('My Offices'),
                    onTap: _navigateToOffices,
                  ),
                ),
              ],
            ),
    );
  }
}
