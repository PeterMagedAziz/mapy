import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mapy_map.dart';
import 'mapy_provider.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Google Maps App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MapSample(),
      ),
    );
  }
}