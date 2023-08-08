import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:timely/backend_models/location_data.dart';
import 'package:timely/controllers/location_controller.dart';

/// This class will handle all Apple Maps related functions
class AppleMaps {
  final String _baseUrl = 'maps-api.apple.com';
  final String? _appleMapsApiKey = dotenv.env['APPLE_MAPS_API_KEY'];
  String? _token;

  // Private constructor
  AppleMaps._internal();

  factory AppleMaps() {
    return _instance;
  }

  // Singleton instance
  static AppleMaps _instance = AppleMaps._internal();

  // Singleton accessor
  void setInstance(AppleMaps instance) {
    _instance = instance;
  }

  /// This method will get the Apple Maps API token
  Future<String> getAppleMapsToken(http.Client client) async {
    if (_appleMapsApiKey == null) {
      developer.log('Apple Maps API Key not found', name: 'getAppleMapsToken');
      throw Exception('Apple Maps API Key not found');
    }

    final response = await client.get(Uri.https(_baseUrl, '/v1/token'),
        headers: {"Authorization": "Bearer $_appleMapsApiKey"});

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['accessToken'];
    } else if (response.statusCode == 401) {
      developer.log('Apple Maps API Key is invalid', name: 'getAppleMapsToken');
      throw Exception('Apple Maps API Key is invalid');
    } else {
      developer.log('Error getting Apple Maps API Token',
          name: 'getAppleMapsToken');
      throw Exception('Error getting Apple Maps API Token');
    }
  }

  /// This method will get the ETA from the current location to the destination
  Future<Map<String, dynamic>?> fetchETA(
      {http.Client? client,
      LocationData? currentPos,
      required String destination}) async {
    LocationData? destinationPos;
    LocationController locator = LocationController();

    client ??= http.Client();
    _token ??= await getAppleMapsToken(client);
    if (currentPos == null) {
      currentPos = await locator.currentLocation();
      developer.log(
          'Current location: ${currentPos.latitude}, ${currentPos.longitude}',
          name: 'fetchETA');
    }
    if (destination.isEmpty) {
      return null;
    }
    destinationPos = await fetchGeocode(destination);

    final uri = Uri.https(_baseUrl, '/v1/etas', {
      'origin': '${currentPos.latitude},${currentPos.longitude}',
      'destinations': '${destinationPos!.latitude},${destinationPos.longitude}',
    });

    developer.log('Fetching ETA', name: 'fetchETA');
    final etaResponse = await client.get(uri, headers: {
      "Authorization": "Bearer $_token",
    });

    switch (etaResponse.statusCode) {
      case 200:
        {
          developer.log('ETA fetched',
              name: 'fetchETA', error: etaResponse.body);
          return jsonDecode(etaResponse.body);
        }
      case 400:
        {
          developer.log('Bad ETA request', name: 'fetchETA');
          throw ArgumentError('Bad ETA request');
        }
      case 401:
        {
          developer.log('Unauthorized ETA request... retrying',
              name: 'fetchETA');
          _token = await getAppleMapsToken(http.Client());
          try {
            await fetchETA(
                client: client,
                currentPos: currentPos,
                destination: destination);
          } catch (e) {
            developer.log('Error getting new token',
                name: 'fetchETA', error: e);
            throw Exception('Error getting new token');
          }
          break;
        }
      default:
        {
          developer.log('Internal error getting ETA',
              name: 'fetchETA', error: etaResponse.body);
          throw Exception('Internal error getting ETA');
        }
    }
    return null;
  }

  /// Returns the geocode for the given address.
  static Future<LocationData?> fetchGeocode(String address) async {
    if (address.isEmpty) {
      return null;
    }
    var response = await http.Client().get(
      Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        'address': address,
        'key': dotenv.env['GOOGLE_MAPS_API_KEY']!,
      }),
    );
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['status'] == 'OK') {
        return LocationData.fromCoordinates(
            json['results'][0]['geometry']['location']['lat'],
            json['results'][0]['geometry']['location']['lng']);
      } else {
        developer.log('Error getting geocode',
            name: 'fetchGeocode', error: json['error_message']);
      }
    } else {
      developer.log('Error getting geocode',
          name: 'fetchGeocode', error: response.body);
      return null;
    }
    return null;
  }

  //TODO: Move to a GoogleMaps class
  static Future<String?> getGoogleTravelTime(String destination) async {
    LocationData? destinationPos;
    LocationController locator = LocationController();
    LocationData? currentPos = await locator.currentLocation();
    if (destination.isEmpty) {
      return null;
    }
    destinationPos = await fetchGeocode(destination);
    final uri =
        Uri.https('maps.googleapis.com', '/maps/api/distancematrix/json', {
      'origins': '${currentPos.latitude},${currentPos.longitude}',
      'destinations': '${destinationPos!.latitude},${destinationPos.longitude}',
      'key': dotenv.env['GOOGLE_MAPS_API_KEY']!,
    });
    final response = await http.Client().get(uri);
    if (response.statusCode == 200) {
      developer.log(
          'Google Travel Time: ${jsonDecode(response.body)['rows'][0]['elements'][0]['duration']['text']}',
          name: 'getGoogleTravelTime');
      return jsonDecode(response.body)['rows'][0]['elements'][0]['duration']
          ['text'];
    } else {
      developer.log('Error getting Google Travel Time',
          name: 'getGoogleTravelTime', error: response.body);
      return null;
    }
  }
}
