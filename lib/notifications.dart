// import 'package:firebase_messaging/firebase_messaging.dart';
//
// Future<String?> getFCMToken() async {
//   // FirebaseMessaging.instance.getToken().then((token){
//   //   print("token $token");
//   // });
//   final fcmToken = await FirebaseMessaging.instance.getToken();
//   return fcmToken;
// }

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:timely/controllers/account_controller.dart';
import 'package:timely/event_models/EventModel.dart';
import 'package:timely/shared/geofence.dart';
import 'shared/maps.dart';
import 'package:timezone/data/latest_all.dart' as initTz;
import 'package:timezone/timezone.dart' as tz;

Future initialize(FlutterLocalNotificationsPlugin notifPlugin) async {
  var androidInitialize =
      const AndroidInitializationSettings('mipmap/ic_launcher');
  var iosInitialize = const DarwinInitializationSettings();
  var initializationSettings =
      InitializationSettings(android: androidInitialize, iOS: iosInitialize);
  await notifPlugin.initialize(initializationSettings);
}

/**
 * Allows for the scheduling of notifications on the device given all the required parameters
 */
Future scheduleEventNotification(
    {var id = 0,
    required String title,
    required String body,
    var payload,
    required FlutterLocalNotificationsPlugin fln,
    required DateTime whenToGo}) async {
  initTz.initializeTimeZones();
  String timezone = 'America/Denver';
  //How documentation of setLocalLocation wants the local location to be set
  tz.setLocalLocation(tz.getLocation(timezone));
  //For android we need these specifics
  AndroidNotificationDetails androidChannelSpecifics =
      const AndroidNotificationDetails('1', 'Depart_Notifications',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'Time to leave for your appointment');

  final tz.TZDateTime scheduledAt = tz.TZDateTime.from(whenToGo, tz.local);
  //For apple
  var notif = NotificationDetails(
      android: androidChannelSpecifics, iOS: const DarwinNotificationDetails());

  await fln.zonedSchedule(0, title, body, scheduledAt, notif,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime);
}





