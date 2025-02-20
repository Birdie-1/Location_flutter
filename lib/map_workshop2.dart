import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';


class GoogleMapWorkshop2 extends StatefulWidget {
  const GoogleMapWorkshop2({super.key});

  @override
  State<GoogleMapWorkshop2> createState() => _GoogleMapWorkshop2State();
}

class _GoogleMapWorkshop2State extends State<GoogleMapWorkshop2> {
  GoogleMapController? _controller;
  LatLng _currentPosition = LatLng(17.45193, 102.93105);
  bool _isLoading = true;

   @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
   var status = await Permission.location.status;
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoading = false;
      });
      _controller?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition,
          zoom: 15.0,
        ),
      ));
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    if (!_isLoading) {
      _controller?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition,
          zoom: 15.0,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map Example'),
        backgroundColor: Colors.green[700],
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 15.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId('currentLocation'),
            position: _currentPosition,
            infoWindow: InfoWindow(title: 'ตำแหน่งของคุณ'),
          ),
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}