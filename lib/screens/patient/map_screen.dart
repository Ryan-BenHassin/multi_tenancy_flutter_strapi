import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../models/office.dart';
import '../../services/office_service.dart';
import '../../utils/showFlushbar.dart';
import '../../widgets/booking_dialog.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController mapController = MapController();
  LatLng? currentLocation;
  List<Office> offices = [];
  late final OfficeService _officeService;

  @override
  void initState() {
    super.initState();
    _officeService = OfficeService();
    _requestLocationPermission();
    _loadOffices();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _goToMyLocation();
    });
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
  }

  Future<void> _goToMyLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition();
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
      mapController.move(currentLocation!, 14,); // Poisitional arguments
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _loadOffices() async {
    try {
      final loadedOffices = await _officeService.fetchOffices();
      setState(() {
        offices = loadedOffices;
      });
    } catch (e) {
      print('Error loading offices: $e');
      if (!mounted) return;
      showFlushBar(
        context,
        message: 'Failed to load offices. Please check your connection.',
        success: false,
        fromBottom: false,
      );
    }
  }

  Future<void> _loadMapData() async {
    try {
      // API call here
    } catch (e) {
      if (mounted) {
        showFlushBar(context, message: 'Failed to load map data', success: false);
      }
    }
  }

  void _showOfficeDetails(Office office) {
    showDialog(
      barrierColor: Colors.black.withOpacity(0.8),
      context: context,
      builder: (context) => AlertDialog(
        title: Text(office.name),
        content: Text(office.description ?? 'No description available'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () => _showBookingDialog(office),
            child: Text('Book'),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(Office office) {
    showDialog(
      context: context,
      builder: (context) => BookingDialog(
        office: office,
        // bookingService: _bookingService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offices Map')),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: LatLng(0, 0),
          zoom: 2,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
            tileProvider: NetworkTileProvider(),
            maxZoom: 19,
            keepBuffer: 5,
          ),
          MarkerLayer(
            markers: [
              if (currentLocation != null)
                Marker(
                  point: currentLocation!,
                  width: 80,
                  height: 80,
                  builder: (context) => Icon(Icons.my_location_rounded, color: Colors.blue, size: 40),
                ),
              // Add markers for offices
              ...offices.map(
                (office) => Marker(
                  point: LatLng(office.latitude, office.longitude),
                  width: 80,
                  height: 80,
                  builder: (context) => GestureDetector(
                    onTap: () => _showOfficeDetails(office),
                    child: Tooltip(
                      message: '${office.name}\n${office.description ?? ""}',
                      child: Icon(Icons.location_on_sharp, color: Colors.red, size: 50),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToMyLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
