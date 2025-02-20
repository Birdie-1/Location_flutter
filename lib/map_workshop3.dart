import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class MapScreen3 extends StatefulWidget {
  @override
  _MapScreen3State createState() => _MapScreen3State();
}

class _MapScreen3State extends State<MapScreen3> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  LatLng _currentPosition = LatLng(13.7563, 100.5018); // Default to Bangkok
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    HttpOverrides.global = MyHttpOverrides();
    _getCurrentLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _fetchMarkers();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _controller?.animateCamera(
        CameraUpdate.newLatLng(_currentPosition),
      );
      _addCurrentLocationMarker();
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  void _addCurrentLocationMarker() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("current_location"),
          position: _currentPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: "Your Location"),
        ),
      );
    });
  }

  Future<void> _fetchMarkers() async {
    try {
      final response = await http.get(Uri.parse('https://hosting.udru.ac.th/its66040233145/flutter_map/get_location.php'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        print("Fetched Data: $data"); // Log the fetched data for debugging

        List<Marker> markersList = data.map((location) {
          try {
            double lat = double.tryParse(location['latitude'].toString()) ?? 0.0;
            double lng = double.tryParse(location['longitude'].toString()) ?? 0.0;

            // Log each marker for debugging
            print("Adding marker: ${location['name']} ($lat, $lng)");

            if (lat != 0.0 && lng != 0.0) {
              return Marker(
                markerId: MarkerId(location['id'].toString()),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(title: location['name']),
              );
            }
            return null;
          } catch (e) {
            print("Error parsing marker: ${location['name']} - $e");
            return null;
          }
        }).where((marker) => marker != null).toList().cast<Marker>();

        setState(() {
          _markers.clear(); // Clear existing markers
          _markers.addAll(markersList);
          _addCurrentLocationMarker(); // Re-add current location marker
        });

        // Adjust camera to show all markers
        if (_markers.isNotEmpty) {
          LatLngBounds bounds = _getLatLngBounds(_markers);
          _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
        }
      } else {
        print('Failed to load markers, Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching markers: $e');
    }
  }

  LatLngBounds _getLatLngBounds(Set<Marker> markers) {
    double minLat = markers.first.position.latitude;
    double maxLat = markers.first.position.latitude;
    double minLng = markers.first.position.longitude;
    double maxLng = markers.first.position.longitude;

    for (var marker in markers) {
      minLat = marker.position.latitude < minLat ? marker.position.latitude : minLat;
      maxLat = marker.position.latitude > maxLat ? marker.position.latitude : maxLat;
      minLng = marker.position.longitude < minLng ? marker.position.longitude : minLng;
      maxLng = marker.position.longitude > maxLng ? marker.position.longitude : maxLng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Maps")),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentPosition, // Ensure this is updated after fetching the location
          zoom: 10.0,
        ),
        myLocationEnabled: true,
        markers: Set.from(_markers),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
