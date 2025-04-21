import 'package:flutter/material.dart';
import 'screens/bookings_screen.dart';
import 'screens/doctor/doctor_bookings_screen.dart';
import 'screens/patient/map_screen.dart';
import 'screens/doctor/doctor_home_screen.dart';
import 'services/auth_service.dart';
import 'providers/user_provider.dart';
import 'screens/auth/profile_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final _authService = AuthService();
  bool isDoctor = false;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final user = await _authService.getCompleteUserData();
    setState(() {
      isDoctor = (user.roleType == 'DOCTOR');
      if (isDoctor) {
        UserProvider.doctorId = user.doctor?['documentId']?.toString();
      }
    });
  }

  Widget _getScreen() {
    if (isDoctor) {
      switch (_selectedIndex) {
        case 0:
          return const DoctorHomeScreen();
        case 1:
          return UserProvider.doctorId != null 
              ? DoctorBookingsScreen(doctorId: UserProvider.doctorId!)
              : const Center(child: Text('Doctor ID not found'));
        case 2:
          return const ProfileScreen();
        default:
          return const DoctorHomeScreen();
      }
    }
    
    // Patient screens
    switch (_selectedIndex) {
      case 0:
        return MapScreen();
      case 1:
        return BookingsScreen();
      case 2:
        return const ProfileScreen();
      default:
        return MapScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: isDoctor ? const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ] : const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'My Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
