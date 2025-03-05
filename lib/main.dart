import 'package:flutter/material.dart';
// import 'map_workshop1.dart';
// import 'map_workshop2.dart';
// import 'map_workshop3.dart';
import 'map_workshop4.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SaveLocation(),
      debugShowCheckedModeBanner: false,
    );
  }
}
