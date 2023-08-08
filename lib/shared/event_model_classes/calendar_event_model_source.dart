import 'package:googleapis/calendar/v3.dart' as googleAPI;
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'event_model.dart';


/// This class will handle data conversion for syncfusion calendar



class CalendarEventModelSource extends CalendarDataSource {
  CalendarEventModelSource({required List<EventModel> events}) {
    appointments = events;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments?[index]?.getStartTime();
  }

  @override
  bool isAllDay(int index) {
    return appointments?[index]?.isAllDay();

  }

  @override
  DateTime getEndTime(int index) {
    return appointments?[index]?.getEndTime();

  }

  @override
  String getLocation(int index) {
    return appointments?[index]?.getLocation();
  }

  @override
  String getNotes(int index) {
    return appointments?[index]?.getNotes();
  }

  @override
  String getSubject(int index) {
    return appointments?[index]?.getSubject();
  }

  @override
  String getRecurrenceRule(int index) {
    return appointments?[index]?.getRecurrenceRule();
  }

  // @override
  // String getRecurrenceId(int index) {
  //   return appointments?[index].recurrenceId  == null
  //       ? ""
  //       : appointments?[index].recurrenceId;
  // }

  /// Returns the color for the appointment based on the color id.
  @override
  Color getColor(int index) {
    return appointments?[index].getColor();
  }


  @override
  Object? convertAppointmentToObject(
      Object? customData, Appointment appointment) {
    // TODO: implement convertAppointmentToObject
    Object returnEvent = customData ?? EventModel();
    if(returnEvent is EventModel)
      returnEvent.editable = true;
      return returnEvent;
    //   if(appointment.isAllDay)
    //     {
    //
    //     }
    // return EventModel(
    //     from: appointment.startTime,
    //     to: appointment.endTime,
    //     eventName: appointment.subject,
    //     background: appointment.color,
    //     isAllDay: appointment.isAllDay,
    //     id: appointment.id,
    //     recurrenceRule: appointment.recurrenceRule,
    //     recurrenceId: appointment.recurrenceId,
    //     exceptionDates: appointment.recurrenceExceptionDates);
  }

}
