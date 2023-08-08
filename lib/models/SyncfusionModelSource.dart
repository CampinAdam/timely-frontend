import 'dart:developer';
import 'dart:ui';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../controllers/account_controller.dart';
import '../controllers/settings_controller.dart';
import '../event_models/EventModel.dart';
import '../event_models/recurring_event_data.dart';
import '../helpers.dart';

import '../backend_models/estimate_data.dart';
import '../backend_models/event_data.dart';
import '../backend_models/location_data.dart' as loc;
import '../shared/maps.dart';

class SyncFusionModelSource extends CalendarDataSource {
  //KEY = "${e.recurrenceRule}${e.subject}"
  // = e.recurrenceRule##e.subject
  Map<String, EventModel> originalRecurrences = {};
  //KEY = "${e.subject}${e.startTime.toString()}${e.endTime.toString()}"
  // = e.subject##e.startTime.toString()##e.endTime.toString()
  Map<String, EventModel> nonRecurringEvents = {};


  SyncFusionModelSource({required List<EventModel> events,timeZone= "America/Denver"}) {
    appointments = events;
    for(EventModel e in events)
      {
        if(e.recurrenceRule != null && e.recurrenceRule != "")
          {
            originalRecurrences["${e.recurrenceRule}${e.subject}"] = e;
          }
        else
          {
            nonRecurringEvents["${e.subject}${e.startTime.toString()}${e.endTime.toString()}"] = e;
          }
      }
  }

  @override
  String? getStartTimeZone(int index) => null;

  @override
  DateTime getStartTime(int index) {
    return appointments?[index]?.startTime;
  }

  @override
  bool isAllDay(int index) {
    return appointments?[index]?.isAllDay;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments?[index]?.endTime;
  }

  @override
  String getLocation(int index) {
    return appointments?[index]?.location ?? "";
  }

  @override
  String getNotes(int index) {
    return appointments?[index]?.notes;
  }

  @override
  String getSubject(int index) {
    return appointments?[index]?.subject;
  }

  @override
  String getRecurrenceRule(int index) {
    return appointments?[index]?.recurrenceRule;
  }


  /// Returns the color for the appointment based on the color id.
  @override
  Color getColor(int index) {

    return const Color.fromARGB(0xFF, 0xff, 0x00, 0xF5);

  }

  @override
  Object? convertAppointmentToObject(
      Object? customData, Appointment appointment) {
    return customData as EventModel;
  }

  /**
   * Returns event model if it's not recurring, returns recurring data object if it is a recurrence
   */
  dynamic getDataFromAppointment(Appointment a) {
    if(a.recurrenceRule == null || a.recurrenceRule == "")
    {
      return nonRecurringEvents["${a.subject}${a.startTime.toString()}${a.endTime.toString()}"];
    }
    return originalRecurrences["${a.recurrenceRule}${a.subject}"]?.recurringData?[a.startTime.toString()];
  }


  double? getTimeEstimate(Appointment a) {
    //get event model or recurrence object, return its estimate in minutes
    var details = getDataFromAppointment(a);
    return details?.estimateInMinutes;
  }

  String? getStartLocation(Appointment a) {
    //get event model or recurrence object, return its startLocation
    var details = getDataFromAppointment(a);
    return details?.startLocation;
  }


  /**
   *  Now we're looking at OUR methods and not things from syncfusion
   */


  Future<void> changeEventInfo(Appointment a, String startAddress) async {
    if(a.location == null || a.location == "") {
      return;
    }
    log("getting appointment: ${a.subject}\t\t ${a.startTime}", name: "setDayEventInfo");
    loc.LocationData? startLocation = await AppleMaps.fetchGeocode(startAddress ?? "");

    loc.LocationData? nextLoc = await AppleMaps.fetchGeocode(a.location ?? "");
    if(nextLoc == null) {
      return;
    }

    //now we know this event has a valid start location
    log("start address: ${startAddress}", name: "setDayEventInfo");

    if (a.recurrenceRule == null || a.recurrenceRule == "") {
      EventModel? e = nonRecurringEvents["${a.subject}${a.startTime
          .toString()}${a.endTime.toString()}"];
      await e?.updateTimeEstimate(startAdd: startAddress ?? "",
          startLoc: startLocation);
    }
    else {
      //get original recurrence
      print("${a.subject} is a recurring event");
      await originalRecurrences["${a.recurrenceRule}${a.subject}"]
          ?.updateTimeEstimate(startAdd: startAddress ?? "",
          recurrenceDate: a.startTime,
          startLoc: startLocation);
    }

    AccountController().saveToFirestore();
    AccountController().notifyListeners();
  }



  Future<void> setDayEventInfo(DateTime day) async {
    DateTime startDay = DateTime(day.year, day.month, day.day, 0,0,0,0,0);
    DateTime endDay = startDay.add(const Duration(days:1));
    List<Appointment> dayEvents = getVisibleAppointments(startDay, "America/Denver", endDay); ///TIMEZONE TODO
    dayEvents.sort((a,b) => a.startTime.compareTo(b.startTime));

    String? startAddress = SettingsController().settingsModel.homeAddress;
    loc.LocationData? startLocation = await AppleMaps.fetchGeocode(startAddress ?? "");

    int counter = 1;

    for(Appointment a in dayEvents)
    {
      log("getting appointment: ${a.subject}\t\t ${a.startTime}", name:"setDayEventInfo");
      //we don't do location stuff for all day events
      if(a.isAllDay)
      {
        counter++;
        continue;
      }
      //prevEvent is last event before our current one that has a location field
      if(a.location == null || a.location == "") {
        continue;
      }

      loc.LocationData? nextLoc = await AppleMaps.fetchGeocode(a.location ?? "");

      if(nextLoc == null)
      {
        continue;
      }
      //now we know this event has a valid start location
      log("start address: ${startAddress}", name:"setDayEventInfo");


      if(a.recurrenceRule == null || a.recurrenceRule == "")
        {
          EventModel? e = nonRecurringEvents["${a.subject}${a.startTime.toString()}${a.endTime.toString()}"];
          await e?.getTimeEstimate(startAdd:startAddress??"", startLoc:startLocation, totalEvents: dayEvents.length, thisEvent:counter);
        }
      else
        {
          //get original recurrence
          print("${a.subject} is a recurring event");
          await originalRecurrences["${a.recurrenceRule}${a.subject}"]?.getTimeEstimate(startAdd:startAddress??"", recurrenceDate:a.startTime,
              startLoc:startLocation, totalEvents: dayEvents.length, thisEvent:counter);
        }
      startAddress = a.location;
      startLocation = nextLoc;


      counter++;
    }
    AccountController().saveToFirestore();
    AccountController().notifyListeners();
  }

}

