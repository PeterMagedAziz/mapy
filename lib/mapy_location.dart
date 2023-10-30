import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
class LocationService{
  final String key = 'AIzaSyCYdVOsF0mLg-OcaKq6dQ6T2qUGd5yMtrk';


  Future<String> getPlaceId(String input) async {
    final String key = 'AIzaSyCYdVOsF0mLg-OcaKq6dQ6T2qUGd5yMtrk'; // Your API key.
    // The url for the API request, with the input and the API key as parameters
    final String url =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key';

    // Try to make the HTTP request and decode the JSON response
    try {
      var response = await http.get(Uri.parse(url));
      var json = convert.jsonDecode(response.body);

      // If the API request was denied, throw an exception
      if (json['status'] == "REQUEST_DENIED") {
        throw Exception(json['error_message']);
      }

      // If the candidates list is not empty, get the place ID of the first candidate and print it
      if (json['candidates'].isNotEmpty) {
        var placeId = json['candidates'][0]['place_id'] as String; // access first place object for place_id
        print(placeId);
        return placeId;
      } else {
        // Handle the case when the list is empty
        throw Exception('No place found for the given input');
      }
    } catch (e) {
      // Handle the error
      print('Error: $e');
      throw Exception('Failed to get place ID: $e');
    }
  }

  // Future<String> getPlaceId(String input) async {
  //   final String url =
  //       'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key';
  //
  //   // var response = await http.get(Uri.parse(url));
  //   try {
  //     var response = await http.get(Uri.parse(url));
  //     var json = convert.jsonDecode(response.body);
  //     // Rest of the code
  //   } catch (e) {
  //     // Handle the error
  //     // For example, print the error message or show an alert dialog
  //   }
  //   // var json = convert.jsonDecode(response.body);
  //   // var placeId = json['candidates'][0]['place_id'] as String;
  //   var json = convert.jsonDecode(response.body);
  //   if (json['candidates'].isNotEmpty) {
  //     var placeId = json['candidates'][0]['place_id'] as String;
  //     print(placeId);
  //     return placeId;
  //   } else {
  //     // Handle the case when the list is empty
  //     // For example, show an error message or ask for a different input
  //   }
  //   // print(placeId);
  //
  //   return placeId;
  // }



  Future<Map<String, dynamic>> getPlace(String input) async {
    final String key = 'AIzaSyCYdVOsF0mLg-OcaKq6dQ6T2qUGd5yMtrk'; // Your API key.

    final placeId = await getPlaceId(input);

    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = json['result'] as Map<String, dynamic>;

    print(results);
    return results;
  }


  Future<Map<String, dynamic>> getDirections(String origin, String destination) async {
    final String key = 'AIzaSyCYdVOsF0mLg-OcaKq6dQ6T2qUGd5yMtrk';
    final String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);

    if (json['status'] == 'OK' && json['routes'] != null && json['routes'].isNotEmpty) {
      var route = json['routes'][0];
      var bounds = route['bounds'];
      var legs = route['legs'];

      if (bounds != null && legs != null && legs.isNotEmpty) {
        var results = {
          'bounds_ne': bounds['northeast'],
          'bounds_sw': bounds['southwest'],
          'start_location': legs[0]['start_location'],
          'end_location': legs[0]['end_location'],
          'polyline': route['overview_polyline']['points'],
          'polyline_decoded': PolylinePoints().decodePolyline(route['overview_polyline']['points']),
        };

        print(results);
        return results;
      }
    }

    throw Exception('Failed to get directions');
  }
}