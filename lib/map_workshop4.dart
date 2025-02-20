import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class SaveLocation extends StatefulWidget {
  const SaveLocation({super.key});

  @override
  State<SaveLocation> createState() => _SaveLocationState();
}

class _SaveLocationState extends State<SaveLocation> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = LatLng(17.4517, 102.9311); // Initial position in Thailand
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Fetch current location on init
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude); // Update current position
      _markers = {
        Marker(
          markerId: MarkerId("Select_location"),
          position: _currentPosition,
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _currentPosition = newPosition;
              _markers = {
                Marker(
                  markerId: MarkerId("Select_location"),
                  position: _currentPosition,
                  draggable: true,
                  onDragEnd: (newPosition) {
                    setState(() {
                      _currentPosition = newPosition;
                    });
                  },
                ),
              };
            });
          },
        ),
      };
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition)); // Ensure camera updates after fetching location
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _getCurrentLocation(); // Get current location once the map is created
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Map Workshop 4")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 15),
            onMapCreated: _onMapCreated,
            markers: _markers,
          ),
        ],
      ),
    );
  }
}
