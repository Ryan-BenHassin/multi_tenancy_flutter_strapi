import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'models/complex.dart';
import 'services/complex_service.dart';
import 'widgets/booking_dialog.dart';
import 'utils/showFlushbar.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController mapController = MapController();
  LatLng? currentLocation;
  List<Complex> complexes = [];
  final ComplexService _complexService = ComplexService();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _loadComplexes();
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

  Future<void> _loadComplexes() async {
    try {
      final loadedComplexes = await _complexService.fetchComplexes();
      setState(() {
        complexes = loadedComplexes;
      });
    } catch (e) {
      print('Error loading complexes: $e');
      if (!mounted) return;
      showFlushBar(
        context,
        message: 'Failed to load complexes. Please check your connection.',
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

  void _showComplexDetails(Complex complex) {
    showDialog(
      barrierColor: Colors.black.withOpacity(0.8),
      context: context,
      builder: (context) => AlertDialog(
        title: Text(complex.name),
        content: Text(complex.description ?? 'No description available'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () => _showBookingDialog(complex),
            child: Text('Book'),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(Complex complex) {
    showDialog(
      context: context,
      builder: (context) => BookingDialog(
        complex: complex,
        // bookingService: _bookingService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complexes Map')),
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
              // Add markers for complexes
              ...complexes.map(
                (complex) => Marker(
                  point: LatLng(complex.latitude, complex.longitude),
                  width: 80,
                  height: 80,
                  builder: (context) => GestureDetector(
                    onTap: () => _showComplexDetails(complex),
                    child: Tooltip(
                      message: '${complex.name}\n${complex.description ?? ""}',
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
