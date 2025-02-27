import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class GoogleMapFromDB extends StatefulWidget {
  const GoogleMapFromDB({super.key});

  @override
  State<GoogleMapFromDB> createState() => _GoogleMapFromDBState();
}

class _GoogleMapFromDBState extends State<GoogleMapFromDB> {

  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  LatLng _currentPosition = LatLng(13.7563, 100.5018);
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentLocation();
    _fetchLocations();
  }
  Future<void> _getCurrentLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });

        _controller?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: 10),
        ));
    } else {
      setState(() {
        _isLoading = false;
      });
      print ("Permission Denied");
    }
  }

  Future<void>_fetchLocations() async {
    HttpOverrides.global = MyHttpOverrides();
   final url = Uri.parse("https://hosting.udru.ac.th/its66040233145/flutter_map/get_location.php");
   final response = await http.get(url);

   if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    Set<Marker> markers = {};

    for (var item in data) {
      final double lat = (item["latitude"] as num).toDouble();
      final double lng = (item["longitude"] as num).toDouble();

      markers.add(
        Marker(
          markerId: MarkerId(item["id"].toString()),
          position: LatLng(lat,lng),
          infoWindow: InfoWindow(title: item["name"]),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
   } else {
    print("Failed to load data");
   }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:AppBar(title: Text("Google Map - MySQL Locations")),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _currentPosition, 
            zoom: 10,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
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
