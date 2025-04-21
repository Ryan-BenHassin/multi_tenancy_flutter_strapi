import 'package:flutter/material.dart';
import '../../models/office.dart';
import '../../services/office_service.dart';
import 'office_creation_screen.dart';

class DoctorOfficesScreen extends StatefulWidget {
  final String doctorId;
  
  const DoctorOfficesScreen({super.key, required this.doctorId});

  @override
  State<DoctorOfficesScreen> createState() => _DoctorOfficesScreenState();
}

class _DoctorOfficesScreenState extends State<DoctorOfficesScreen> {
  final _officeService = OfficeService();
  List<Office> offices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOffices();
  }

  Future<void> _loadOffices() async {
    try {
      final loadedOffices = await _officeService.getDoctorOffices(widget.doctorId);
      setState(() {
        offices = loadedOffices;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load offices: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Offices')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : offices.isEmpty
              ? const Center(child: Text('No offices yet'))
              : ListView.builder(
                  itemCount: offices.length,
                  itemBuilder: (context, index) {
                    final office = offices[index];
                    return ListTile(
                      title: Text(office.name),
                      subtitle: Text(office.description ?? 'No description'),
                      trailing: Text('${office.latitude}, ${office.longitude}'),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OfficeCreationScreen(doctorId: widget.doctorId),
            ),
          );
          if (result == true) {
            _loadOffices();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
