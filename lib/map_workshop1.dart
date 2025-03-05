import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapWorkshop1 extends StatefulWidget {
  const GoogleMapWorkshop1({super.key});

  @override
  State<GoogleMapWorkshop1> createState() => _GoogleMapWorkshop1State();
}

class _GoogleMapWorkshop1State extends State<GoogleMapWorkshop1> {

  GoogleMapController? _controller;
  static const LatLng _center = LatLng(17.45193, 102.93105);

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map Example'),
        backgroundColor: Colors.green[700],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target:_center,
          zoom: 15.0,
        ),
      ),
    );
  }
}