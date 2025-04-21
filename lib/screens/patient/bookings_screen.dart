import 'package:flutter/material.dart';
import 'package:mapbox_first/services/booking_service.dart';
import 'package:intl/intl.dart';
import '../../utils/showFlushbar.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';

class BookingsScreen extends StatefulWidget {
  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final BookingService _bookingService = BookingService();
  final _authService = AuthService();
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  bool _isDoctor = false;
  String? _doctorId;

  @override
  void initState() {
    super.initState();
    _checkRoleAndLoadData();
  }

  Future<void> _checkRoleAndLoadData() async {
    try {
      final user = await _authService.getCompleteUserData();
      _isDoctor = user.roleType == 'DOCTOR';
      if (_isDoctor) {
        _doctorId = user.doctor?['documentId']?.toString();
      }
      _loadBookings();
    } catch (e) {
      print('Error checking role: $e');
    }
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      if (_isDoctor && _doctorId != null) {
        final bookings = await _bookingService.fetchDoctorBookings(_doctorId!);
        setState(() => _bookings = bookings);
      } else {
        final bookings = await _bookingService.fetchUserBookings(
          userID: UserProvider.user!.id,
        );
        setState(() => _bookings = bookings);
      }
    } catch (e) {
      print('Error loading bookings: $e');
      if (!mounted) return;
      showFlushBar(
        context,
        message: 'Failed to load ${_isDoctor ? 'bookings' : 'bookings'}',
        success: false,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isDoctor ? 'My Bookings' : 'My Bookings'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBookings,
              child: _bookings.isEmpty
                  ? Center(
                      child: Text(_isDoctor
                          ? 'No bookings found'
                          : 'No bookings found'),
                    )
                  : ListView.builder(
                      itemCount: _bookings.length,
                      itemBuilder: (context, index) {
                        final booking = _bookings[index];
                        DateTime? date;
                        try {
                          date = DateTime.parse(booking['date']).toLocal();
                        } catch (e) {
                          date = DateTime.now();
                        }

                        final formattedDate = DateFormat('MMM d, y - HH:mm').format(date);
                        final office = booking['office'] ?? {};
                        final patient = booking['patient'] ?? {};
                        final status = booking['status_booking'] ?? 'PENDING';

                        return Card(
                          child: ListTile(
                            title: Text(office['title'] ?? 'Unknown Office'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(formattedDate),
                                if (_isDoctor && patient != null)
                                  Text('Patient ID: ${patient['documentId'] ?? 'Unknown'}'),
                                Text('Status: $status', 
                                  style: TextStyle(
                                    color: status == 'PENDING' 
                                      ? Colors.orange 
                                      : status == 'APPROVED' 
                                        ? Colors.green 
                                        : Colors.red
                                  ),
                                ),
                              ],
                            ),
                            trailing: _isDoctor ? PopupMenuButton(
                              itemBuilder: (context) => [
                                if (status == BookingService.STATUS_PENDING) ...[
                                  const PopupMenuItem(
                                    value: BookingService.STATUS_CONFIRMED,
                                    child: Text('Confirm'),
                                  ),
                                  const PopupMenuItem(
                                    value: BookingService.STATUS_REJECTED,
                                    child: Text('Reject'),
                                  ),
                                ],
                                if (status == BookingService.STATUS_CONFIRMED)
                                  const PopupMenuItem(
                                    value: BookingService.STATUS_CANCELED,
                                    child: Text('Cancel'),
                                  ),
                              ],
                              onSelected: (value) async {
                                final success = await _bookingService.updateAppointmentStatus(
                                  booking['documentId'],
                                  value,
                                );
                                if (success && mounted) {
                                  _loadBookings();
                                }
                              },
                            ) : null,
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
