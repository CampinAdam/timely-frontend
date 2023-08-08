import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart' as http;

import 'package:timely/event_models/EventModel.dart';
import 'package:timely/event_models/MicrosoftEvent.dart';
import 'package:timely/models/calendar_model.dart';
import 'package:timely/controllers/account_controller.dart';

class MicrosoftCalendarModel extends CalendarModel {
  String? calendarGroup;


  MicrosoftCalendarModel(super.id, super.account,
      {String? group, List<MicrosoftEvent>? events, bool? editable, String? calColor}) {
    calendarGroup = group;
    if(editable != null)
      {
        canEdit = editable;
      }
    if(calColor != null)
    {
      color = calColor;
    }
  }

  @override
  EventModel createEvent(DateTime start, DateTime end, String subject, bool isAllDay) {
    MicrosoftEvent event = MicrosoftEvent(startTime: start, endTime: end, subject: subject, isAllDay: isAllDay, calendar: this);
    return event;
  }

  @override
  Future<Map<String, List<EventModel>>> update() async{
    List<EventModel> oldEvents = events;
    events = <EventModel>[];

    Uri uri;
    if (calendarGroup != null) {
      uri = Uri.parse('https://graph.microsoft.com/v1.0/me/calendarGroups/$calendarGroup/calendars/$id/events');
    }
    else {
      uri = Uri.parse('https://graph.microsoft.com/v1.0/me/calendars/$id/events');
    }
    final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${account.token}',
        'Content-Type': 'application/json'
      });

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> json = jsonDecode(response.body);
      List<MicrosoftEvent>? microsoftEvents;
      print("here in code");
      print(json.toString());
      if (json['value'] != null) {
        var eventsObjsJson = json['value'] as List;
        print(eventsObjsJson);
        microsoftEvents = eventsObjsJson
            .map((eventJson) => MicrosoftEvent.fromMicrosoftJson(eventJson, this))
            .toList();
      }
      if (microsoftEvents != null) {
        for (MicrosoftEvent event in microsoftEvents) {
          events.add(event);
        }
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load calendar');
    }
    Map<String, List<EventModel>> changeLists = <String, List<EventModel>>{};
    changeLists['added'] = <EventModel>[];
    changeLists['deleted'] = <EventModel>[];
    changeLists['updated'] = <EventModel>[];
    int compareEvents(EventModel m1, EventModel m2) => m1.id.toString().compareTo(m2.id.toString());
    oldEvents.sort(compareEvents);
    // for each new event
    for (EventModel event in events) {
      MicrosoftEvent mEvent = event as MicrosoftEvent;
      EventModel? match;
      // find the corresponding old event (binary search)
      int start = 0;
      int end = oldEvents.length - 1;
      int index = ((end + start) / 2).toInt();
      while (start <= end) {
        if (mEvent.id.toString().compareTo(oldEvents[index].id.toString()) == 0) {
          match = oldEvents[index];
          break;
        }
        else if (mEvent.id.toString().compareTo(oldEvents[index].id.toString()) < 0) {
          end = index - 1;
          index = ((end + start) / 2).toInt();
        }
        else {
          start = index + 1;
          index = ((end + start) / 2).toInt();
        }
      }
      // if no matching event, then it is added
      if (match == null) {
        changeLists['added']!.add(event);
      }
      else {
        // otherwise remove its match from the old list and check if it was changed
        oldEvents.remove(match);
        mEvent.backendId = match.backendId;
        mEvent.estimateInMinutes = match.estimateInMinutes;
        mEvent.startLocation = match.startLocation;
        if (!mEvent.equals(match)) {
          changeLists['updated']!.add(event);
        }
      }
    }
    // then all remaining old events don't have a corresponding new event
    // so they were deleted
    for (EventModel deletedEvent in oldEvents) {
      changeLists['deleted']!.add(deletedEvent);
    }
    return changeLists;
  }

  @override
  Map toJson() {
    List<Map> events = this.events.map((i) => i.toJson()).toList();
    print("TO Json " + color.toString());
    return {
      'id': id,
      'events': events,
      'canEdit': canEdit,
      'color' : color,
    };
  }

  factory MicrosoftCalendarModel.fromJson(dynamic json, Account account) {
    String id = json['id'];
    List<MicrosoftEvent>? events;
    MicrosoftCalendarModel cal = MicrosoftCalendarModel(id, account);
    if (json['events'] != null) {
      var eventsObjsJson = json['events'] as List;
      events = eventsObjsJson
          .map((eventJson) => MicrosoftEvent.fromJson(eventJson, cal))
          .toList();
      cal.events = events;
    }
    cal.canEdit = json['canEdit'] ?? false;
    print("From Json ${json['color']}");

    cal.color =json['color'] ?? "0078d4";
    return cal;
  }

}