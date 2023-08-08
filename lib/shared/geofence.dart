import 'dart:async';
import 'dart:developer';

import 'package:geolocator/geolocator.dart';

import '../backend_models/arrival_data.dart';
import '../backend_models/location_data.dart';

/**
 * Will keep track of when the user left their initial location
 * When they arrived to their final destination
 * Post all the arrival data to the backend once done
 */
Future<void> trackingLocation(double geoLat, double geoLon, bool initialSpot, DateTime endTime, LocationData? finalDestination, DateTime departed, int backendID, DateTime sentNotif)async {
  List<Future> futureList = [];
  late LocationSettings locationSettings;
  //Allows us to run the location stream in the applications background
  locationSettings = AndroidSettings(
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationText:
        "Example app will continue to receive your location even when you aren't using it",
        notificationTitle: "Running in Background",
        enableWakeLock: true,
      ));
  //ADDS THE GEOFENCE and starts tracking their location
  StreamSubscription<Position>? positionStream;
  //START THE SUBSCRIPTION TO BEGIN REGISTERING THE GEOFENCE
  positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings)
      .listen((Position? position) async {
    log('This is Us $position');

    //Determine the distance in meters of how far user is to location
    double currlat = position?.latitude ?? 0;
    double currlon = position?.longitude ?? 0;
    double distanceInMeters = Geolocator.distanceBetween(
      currlat,
      currlon,
      geoLat,
      geoLon,
    );

    //IF our current time is greater than the endTime then that means they never left starting location
    var didntLeave = DateTime.now().compareTo(endTime);
    log("The difference in time : $didntLeave", name: "the time");
    if (didntLeave >= 0) {
      positionStream!.cancel();

      log('we ended early cause you didnt leave for event');
    }

    //If they left their initial location then we log a message to console
    //Post estimate data to the backend
    //Change the leaveSpot variable to know hold the coordinates of destination
    if (distanceInMeters > 50 && initialSpot) {
      log('You left Starting Spot! $distanceInMeters');
      geoLat = finalDestination!.latitude;
      geoLon = finalDestination!.longitude;
      initialSpot = false;
      departed = DateTime.now();
    } else if (distanceInMeters < 50 && !initialSpot) {
      log('You made it! $distanceInMeters');
      positionStream!.cancel();
      final arrival = ArrivalData(
          backendID,
          0,
          sentNotif,
          TravelMode.D,
          departed,
          departed,
          null,
          null,
          null,
          DateTime.now(),
          null);
      final arrivalId = await arrival.postData();
      log('Arrival ID: $arrivalId');
    } else {
      log('Nope');
    }

  });

  futureList.add(positionStream.asFuture());
  await Future.wait(futureList);
}