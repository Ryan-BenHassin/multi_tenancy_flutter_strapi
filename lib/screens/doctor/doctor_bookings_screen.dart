import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/booking_service.dart';
import '../../utils/showFlushbar.dart';

class DoctorBookingsScreen extends StatefulWidget {
  final String doctorId;

  const DoctorBookingsScreen({
    super.key,
    required this.doctorId,
  });

  @override
  State<DoctorBookingsScreen> createState() => _DoctorBookingsScreenState();
}

class _DoctorBookingsScreenState extends State<DoctorBookingsScreen> {
  final BookingService _bookingService = BookingService();
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final bookings = await _bookingService.fetchDoctorBookings(widget.doctorId);
      setState(() => _bookings = bookings);
    } catch (e) {
      print('Error loading bookings: $e');
      if (!mounted) return;
      showFlushBar(
        context,
        message: 'Failed to load bookings',
        success: false,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBookings,
              child: _bookings.isEmpty
                  ? const Center(child: Text('No bookings found'))
                  : ListView.builder(
                      itemCount: _bookings.length,
                      itemBuilder: (context, index) {
                        final booking = _bookings[index];
                        final date = DateTime.parse(booking['date']).toLocal();
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
                                Text('Patient ID: ${patient['documentId'] ?? 'Unknown'}'),
                                Text(
                                  'Status: $status',
                                  style: TextStyle(
                                    color: status == BookingService.STATUS_PENDING
                                        ? Colors.orange
                                        : status == BookingService.STATUS_CONFIRMED
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                if (status == BookingService.STATUS_PENDING) ...[
                                  PopupMenuItem(
                                    value: BookingService.STATUS_CONFIRMED,
                                    child: Text('Confirm'),
                                  ),
                                  PopupMenuItem(
                                    value: BookingService.STATUS_REJECTED,
                                    child: Text('Reject'),
                                  ),
                                ],
                                if (status == BookingService.STATUS_CONFIRMED)
                                  PopupMenuItem(
                                    value: BookingService.STATUS_CANCELED,
                                    child: Text('Cancel'),
                                  ),
                              ],
                              onSelected: (value) async {
                                final success = await _bookingService.updateAppointmentStatus(
                                  booking['documentId'],
                                  value.toString(),
                                );
                                if (success && mounted) {
                                  _loadBookings();
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
