import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapWorkshop2 extends StatefulWidget {
  const GoogleMapWorkshop2({super.key});

  @override
  State<GoogleMapWorkshop2> createState() => _GoogleMapWorkshop2State();
}

class _GoogleMapWorkshop2State extends State<GoogleMapWorkshop2> {
  GoogleMapController? _controller;
  static const LatLng _center = LatLng(17.45193, 102.93105);
  final Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('id-1'),
          position: _center,
          infoWindow: InfoWindow(
            title: 'My Location',
            snippet: '17.45193, 102.93105',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map Workshop 2'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
        markers: _markers,
      ),
    );
  }
}