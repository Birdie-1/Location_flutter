import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class SaveLocation extends StatefulWidget {
  const SaveLocation({super.key});

  @override
  State<SaveLocation> createState() => _SaveLocationState();
}

class _SaveLocationState extends State<SaveLocation> {
  GoogleMapController? _controller;
  LatLng _currentPosition = LatLng(17.4517, 102.9311);
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _getCurrentLocation();
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

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition,
          zoom: 16,
        ),
      ),
    );
  } // <--- Closing brace was missing here

  Future<void>_saveLocation() async {
    if(_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาป้อนชื่อสถานที่...'))
      );
      return;
    }
    HttpOverrides.global = MyHttpOverrides();

    final url = Uri.parse("https://hosting.udru.ac.th/its66040233145/flutter_map/get_location.php");

    final response = await http.post(url, body: {
      'name' : _nameController.text,
      'latitude' : _currentPosition.latitude.toString(),
      'longitude' : _currentPosition.longitude.toString(),
    });

    final result = jsonDecode(response.body);
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("บันทึกตำแหน่งสำเร็จ!")));
      _nameController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Save Location'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            markers: {
              Marker(
                  markerId: MarkerId("Select Location"),
                  position: _currentPosition,
                  draggable: true,
                  onDragEnd: (newPosition) {
                    setState(() {
                      _currentPosition = newPosition;
                    });
                  }),
            },
          ),
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText:"ป้อนชื่อสถานที่.....",
                filled: true, 
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)
                )
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override 
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context) 
    ..badCertificateCallback = (X509Certificate cert,String host,int port) => true;
  }
}
