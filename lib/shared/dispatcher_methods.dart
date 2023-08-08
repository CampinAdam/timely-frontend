import 'dart:async';
import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timely/controllers/account_controller.dart';
import 'package:timely/models/SyncFusionModelSource.dart';
import 'package:workmanager/workmanager.dart';

import '../backend_models/arrival_data.dart';
import '../backend_models/location_data.dart';
import '../event_models/EventModel.dart';
import '../event_models/recurring_event_data.dart';
import '../notifications.dart';
import 'geofence.dart';
import 'maps.dart';


/**
 * Calculates all the daily estimates for the day with the help of the syncfusion calendar
 * Will run each estimate based starting at the home address or the last recorded event location
 */
Future<void> calculateAllDailyEstimates(AccountController accountController, SyncFusionModelSource eventData)async {
  //Setup the delay to be the next day
  var delayTime = 24 - DateTime.now().hour + 1;
  //Send estimate data to the backend and save it to firestore
  await eventData.setDayEventInfo(DateTime.now());
  await accountController.saveToFirestore();
  //reschedule the next one off task
  await Workmanager().registerOneOffTask(
      "Send info to backend again", "daily",
      initialDelay: Duration(hours: delayTime));
}

/**
 * Figure out what the next upcoming event in the day is and then:
 * Sends notification of when to leave
 * Tracks Location
 * Sends data to the backend
 * All done through additional helpers
 */
Future<bool> upcomingEventPlanner(SyncFusionModelSource eventData)async {
  //Grab list of appointments and set up notification
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await initialize(flutterLocalNotificationsPlugin);
  List<Appointment> todayAppointments = await grabTodaysAppointments(eventData);
  todayAppointments.sort((a,b) => a.startTime.compareTo(b.startTime));

  //Required fields for geofence/notification/backend posting
  String eventDestination;
  double whenToNotify;
  String title;
  DateTime startTime;
  DateTime endTime;
  int backendID;

  //Find the next upcoming event in the day
  Appointment a = todayAppointments.firstWhere((element) => DateTime.now().compareTo(element.startTime) <= 0 && DateTime.now().day == element.startTime.day);

  DateTime date = DateTime.now();
  Position currTemp = await Geolocator.getCurrentPosition();
  //THE FOLLOWING IF ELSE checks type of appointment then sets the required fields
  if (a.recurrenceRule == null || a.recurrenceRule == "") { //Its an event model
    //this is how we get that original eventmodel
    EventModel? e = eventData.nonRecurringEvents[
    "${a.subject}${a.startTime.toString()}${a.endTime.toString()}"];

    //Calculate new estimate for the event
    await e?.updateTimeEstimate(startAdd: "From location at ${date.hour}:${date.minute}:${date.second}", startLoc: LocationData.fromCoordinates(currTemp.latitude, currTemp.longitude),
        recurrenceDate: null);

    //Set all the required fields for all the upcoming methods
    eventDestination = e?.location ?? "";
    whenToNotify = e?.estimateInMinutes ?? 0;
    title = e?.subject ?? "";
    startTime = e?.startTime ?? DateTime.now();
    backendID = e?.backendId ?? 0;
    endTime = e?.endTime ?? DateTime.now();
  } else //otherwise it's a recurring event
      {
    //now we can get the RecurringEventData associated with this recurring event
    EventModel? e = eventData.originalRecurrences["${a.recurrenceRule}${a.subject}"];
    RecurringEventData? r = eventData.originalRecurrences["${a.recurrenceRule}${a.subject}"]?.recurringData?[a.startTime.toString()];

    //Calculate new estimate for the event
    await e?.updateTimeEstimate(startAdd: "From location at ${date.hour}:${date.minute}:${date.second}", startLoc: LocationData.fromCoordinates(currTemp.latitude, currTemp.longitude),
        recurrenceDate: a.startTime);

    //Set all the required fields for all the upcoming methods
    eventDestination = a?.location ?? "";
    whenToNotify = r?.estimateInMinutes ?? 0;
    title = e?.subject ?? "";
    startTime = r?.date ?? DateTime.now();
    backendID = r?.backendId ?? 0;
    endTime = e?.endTime ?? DateTime.now();
  }

  //Using the response from backend we calculate when we need to leave
  //Then check if our current time and the calculated time are within 15 min
  DateTime whenToGo = startTime.subtract(Duration(minutes: whenToNotify.round()));
  DateTime withinRange = DateTime.now();
  int difference = withinRange.difference(whenToGo).inMinutes;

  if (difference <= 15) {
    //Schedule the notification for event and track when sent
    DateTime sentNotif = DateTime.now().add(const Duration(seconds: 30));
    await scheduleEventNotification(
        title: "Uh Oh Time to run",
        body: "Head to your meeting,$title",
        fln: flutterLocalNotificationsPlugin,
        whenToGo: sentNotif);

    //Obtain the current location of the user at the time of the notification then setup variables for backend posting
    Position leaveSpot = await Geolocator.getCurrentPosition();
    var finalDestination = await AppleMaps.fetchGeocode(
        eventDestination ??
            "72 Central Campus Dr, Salt Lake City, UT 84112");
    var initialSpot = true;
    var geoLat = leaveSpot.latitude;
    var geoLon = leaveSpot.longitude;
    DateTime departed = DateTime.now();

    //Checking if the user already happens to be at starting location
    if(await alreadyAtDest(finalDestination, geoLat, geoLon, backendID, sentNotif, departed)){
      return Future.value(true);
    }

    //Now that we know they are not at their event start tracking location
    await trackingLocation(geoLat, geoLon, initialSpot, endTime, finalDestination, departed, backendID, sentNotif);
  }
  return Future.value(true);
}


/**
 * Using the Syncfusion calendar, I grab all the events that start today
 * In chronological order
 */
Future<List<Appointment>> grabTodaysAppointments(SyncFusionModelSource eventData) async{

  DateTime rightnow = DateTime.now();
  //let's get the start of the day
  DateTime startDay = DateTime(
      rightnow.year, rightnow.month, rightnow.day, 0, 0, 0, 0, 0);
  //and now the end of the day
  DateTime endDay = startDay.add(const Duration(days: 1));
  //now we can grab all of the events between those times
  List<Appointment> todayAppointments = eventData.getVisibleAppointments(
      startDay, "America/Denver", endDay);

  return todayAppointments;
}

/**
 * Checks if the user is already at the starting destination of event
 * If so, then posts the Arrival Data to the backend, then returns true
 * Otherwise returns false
 */
Future<bool> alreadyAtDest(LocationData? finalDestination, double geoLat, double geoLon, int backendID, DateTime sentNotif, DateTime departed) async {
  if (Geolocator.distanceBetween(finalDestination?.latitude ?? 0, finalDestination?.longitude ?? 0,
    geoLat, geoLon,) < 10) {
    final arrival = ArrivalData(backendID, null, sentNotif, TravelMode.D, departed, departed, null, null, null, DateTime.now(), null);
    final arrivalId = await arrival.postData();
    return true;
  }
  return false;

}





