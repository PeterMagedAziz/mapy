import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapy/mapy_location.dart';
import 'package:provider/provider.dart';
import 'mapy_provider.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key? key})
      : super(key: key); // Add the named 'key' parameter

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();
  TextEditingController originController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  Set<Marker> markers = <Marker>{};
  Set<Polygon> polygon = <Polygon>{};
  Set<Polyline> polyline = <Polyline>{};
  List<LatLng> polygonLatLngs = <LatLng>[];
  int polygonIdCounter = 1;
  int polylineIdCounter = 1;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(30.000047, 30.959273),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();

    setMarker(const LatLng(30.000047, 30.959273));
  }

  void setMarker(LatLng point) {
    setState(() {
      markers.add(Marker(markerId: const MarkerId('marker'), position: point));
    });
  }


  void setPolygon() {
    final String polygonIdVal = 'polygon$polygonIdCounter';
    polygonIdCounter++;

    polygon.add(
      Polygon(
        polygonId: PolygonId(polygonIdVal),
        points: polygonLatLngs,
        strokeWidth: 2,
        fillColor: Colors.transparent,
      ),
    );
  }


  void setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline$polylineIdCounter';
    polylineIdCounter++;

    polyline.add(
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
        )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapState = Provider.of<MapState>(context); // Move this line here

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Mapy')),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      controller: mapState.originController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                          hintText: 'Origin Place'),
                      onChanged: (value) {
                        print(value);
                      },
                    ),
                    TextFormField(
                      controller: mapState.destinationController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                          hintText: 'Destination Place'),
                      onChanged: (value) {
                        print(value);
                      },
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  var directions = await LocationService().getDirections(originController.text,
                      destinationController.text);
                  _goToPlace(
                      directions['start_location']['lat'],
                      directions['start_location']['lng'],
                      directions['bounds_ne'],
                      directions['bounds_sw']
                  );

                  setPolyline(directions['polyline_decoded']);
// var place = await LocationService()
// .getPlaceId(mapState.searchController.text);
// _goToPlace(place as Map<String, dynamic>);
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              markers: mapState.markers,
              polygons: polygon,
              polylines: polyline,
              initialCameraPosition: mapState.initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (point) {
                setState(() {
                  polygonLatLngs.add(point);
                  setPolygon();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToPlace(
// Map<String, dynamic> place,
      double lat,
      double lng,
      Map<String, dynamic> boundsNe,
      Map<String, dynamic> boundsSw,
      ) async {
// final double lat = place['geometry']['location']['lat'];
// final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12),
      ),
    );

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
          ),
          25),
    );
    setMarker(LatLng(lat, lng));
  }
}