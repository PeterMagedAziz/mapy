
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapState extends ChangeNotifier {
  LatLng currentLocation = const LatLng(30.000047, 30.959273);
  CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(30.000047, 30.959273),
    zoom: 14.4746,
  );
  Set<Marker> markers = {};
  TextEditingController originController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  void addMarker(String id, LatLng location) {
    final marker = Marker(
      markerId: MarkerId(id),
      position: location,
      infoWindow: const InfoWindow(
        title: 'Title of Place',
        snippet: 'Some Description of the place',
      ),
    );
    markers.add(marker);
    notifyListeners();
  }
}