// To parse this JSON data, do
//
//     final eventModel = eventModelFromJson(jsonString);
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as googleAPI;
import 'dart:convert';

import 'event_model_subclasses/event_organizer.dart';
import 'event_model_subclasses/event_attendee.dart';
import 'event_model_subclasses/event_creator.dart';
import 'event_model_subclasses/event_end.dart';
import 'event_model_subclasses/event_override.dart';
import 'event_model_subclasses/event_reminders.dart';
import 'event_model_subclasses/event_source.dart';

EventModel eventModelFromJson(String str) => EventModel.fromJson(json.decode(str));

String eventModelToJson(EventModel data) => json.encode(data.toJson());

class EventModel {
    EventModel({
        this.calType,
        this.kind,
        this.etag,
        this.id,
        this.status,
        this.htmlLink,
        this.created,
        this.updated,
        this.summary,
        this.description,
        this.location,
        this.creator,
        this.organizer,
        this.start,
        this.end,
        this.endTimeUnspecified,
        this.transparency,
        this.visibility,
        this.iCalUid,
        this.sequence,
        this.attendees,
        this.guestsCanInviteOthers,
        this.privateCopy,
        this.reminders,
        this.source,
        this.eventType,
        this.colorId,
        this.recurrence,
        this.recurrenceId,
        this.calendarId,

    });


    EventModel.fromGoogle(googleAPI.Event event)
    {
        calType = "Google";
        kind = event.kind;
        etag = event.etag;
        id = event.id;
        status = event.status;
        htmlLink = event.htmlLink;
        created = event.created;
        updated = event.updated;
        summary = event.summary;
        description = event.description;
        location = event.location;
        creator = Creator.details(event.creator?.displayName, event.creator?.email, event.creator?.id, event.creator?.self);
        organizer = Organizer.details(event.organizer?.email, event.organizer?.displayName, event.organizer?.self);
        start = End.details(event.start?.dateTime, event.start?.timeZone, event.start?.date);
        end = End.details(event.end?.dateTime, event.end?.timeZone, event.end?.date);
        endTimeUnspecified = event.endTimeUnspecified;
        transparency = event.transparency;
        visibility = event.visibility;
        iCalUid = event.iCalUID;
        sequence = event.sequence;

        List<Attendee> newAttendees = <Attendee>[];
        List<googleAPI.EventAttendee>? tempAttendees = event.attendees;
        if(tempAttendees != null)
        {
            for(var a in tempAttendees)
            {
                newAttendees.add(Attendee.details(a.email, a.self, a.responseStatus));
            }
        }
        attendees = newAttendees;
        this.guestsCanInviteOthers = event.guestsCanInviteOthers;
        this.privateCopy = event.privateCopy;

        //this.reminders ?. event.reminders;
        //Override? tempOverride = Override.details(event?.reminders?.overrides?.method, event.reminders.overrides.minutes);
        this.reminders = Reminders.someDetails(event.reminders?.useDefault);
        /*********************** unclear how to fix the overrides property -- TODO: fix later **************/
        bool? guestsCanInviteOthers;
        bool? privateCopy;
        Reminders? reminders;
        source = Source.details(event.source?.url, event.source?.title);
        eventType = event.eventType;
        colorId = event.colorId;
        recurrence = event.recurrence;
        //this.recurrenceId = event.recurringEventId;
    }



    String? calType;
    String? kind;
    String? etag;
    String? id;
    String? status;
    String? htmlLink;
    DateTime? created;
    DateTime? updated;
    String? summary;
    String? description;
    String? location;
    Creator? creator;
    Organizer? organizer;
    End? start;
    End? end;
    bool? endTimeUnspecified;
    String? transparency;
    String? visibility;
    String? iCalUid;
    int? sequence;
    List<Attendee>? attendees;
    bool? guestsCanInviteOthers;
    bool? privateCopy;
    Reminders? reminders;
    Source? source;
    String? eventType;
    String? colorId;
    List<String>? recurrence;
    String? recurrenceId;
    String? calendarId;
    bool editable = false;

    factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        kind: json["kind"],
        etag: json["etag"],
        id: json["id"],
        status: json["status"],
        htmlLink: json["htmlLink"],
        created: DateTime.parse(json["created"]),
        updated: DateTime.parse(json["updated"]),
        summary: json["summary"],
        description: json["description"] == null ? null : json["description"],
        location: json["location"],
        creator: Creator.fromJson(json["creator"]),
        organizer: Organizer.fromJson(json["organizer"]),
        start: End.fromJson(json["start"]),
        end: End.fromJson(json["end"]),
        endTimeUnspecified: json["endTimeUnspecified"] == null ? null : json["endTimeUnspecified"],
        transparency: json["transparency"],
        visibility: json["visibility"],
        iCalUid: json["iCalUID"],
        sequence: json["sequence"],
        attendees: json["attendees"] == null ? null : List<Attendee>.from(json["attendees"].map((x) => Attendee.fromJson(x))),
        guestsCanInviteOthers: json["guestsCanInviteOthers"] == null ? null : json["guestsCanInviteOthers"],
        privateCopy: json["privateCopy"] == null ? null : json["privateCopy"],
        reminders: Reminders.fromJson(json["reminders"]),
        source: json["source"] == null ? null : Source.fromJson(json["source"]),
        eventType: json["eventType"],
        colorId: json["colorId"],
        recurrence: json["recurrence"] == null ? null : List<String>.from(json["recurrence"].map((x) => jsonDecode(x))),
        //recurrence: json["recurrence"] == null ? null : List<String>.from(json["recurrence"].map((x) => json["recurrence"])),
        recurrenceId: json["recurrenceId"],
        calendarId: json["calendarId"],
    );

    Map<String, dynamic> toJson() => {
        "kind": kind,
        "etag": etag,
        "id": id,
        "status": status,
        "htmlLink": htmlLink,
        "created": created?.toIso8601String(),
        "updated": updated?.toIso8601String(),
        "summary": summary,
        "description": description == null ? null : description,
        "location": location,
        "creator": creator?.toJson(),
        "organizer": organizer?.toJson(),
        "start": start?.toJson(),
        "end": end?.toJson(),
        "endTimeUnspecified": endTimeUnspecified == null ? null : endTimeUnspecified,
        "transparency": transparency,
        "visibility": visibility,
        "iCalUID": iCalUid,
        "sequence": sequence,
        "attendees": attendees == null ? null : List<dynamic>.from(attendees?.map((x) => x.toJson()) ?? <dynamic>[]),
        "guestsCanInviteOthers": guestsCanInviteOthers == null ? null : guestsCanInviteOthers,
        "privateCopy": privateCopy == null ? null : privateCopy,
        "reminders": reminders?.toJson(),
        "source": source == null ? null : source?.toJson(),
        "eventType": eventType,
        "colorId": colorId,
        "recurrence": recurrence == null ? null : List<String>.from(recurrence?.map((x) => jsonEncode(x)) ?? <String>[]),
        "recurrenceId": recurrenceId,
        "calendarId": calendarId,
    };

    /*
            METHODS FOR USE WITH EVENT_DATA

     */

    DateTime getStartTime()
    {
        DateTime? test = start?.date ?? start?.dateTime?.toLocal();
        if (test != null) {
            return test;
        } else {
            return DateTime.now();
        }
    }

    bool isAllDay() {
        if (start == null) {
            return false;
        } else {
            return start?.date != null;
        }
    }

    DateTime getEndTime() {
        DateTime? test = end?.date ?? end?.dateTime?.toLocal();
        if (test != null) {
            if(isAllDay())
            {
                return test.subtract(const Duration(days: 1));
            }
            return test;
        } else {
            return DateTime.now();
        }
    }

    String getLocation() {
        if (location != null) {
            return location ?? "";
        } else {
            return "";
        }
    }

    String getNotes() {
        return description ?? "";

    }

    String getSubject() {
        return summary ?? "";
    }

    String getRecurrenceRule() {
        // print(appointments?[index].recurrence);
        return recurrence?[0] ??  "";
    }
    Color getColor() {
        var hexString = colorId;
        final buffer = StringBuffer();
        if (hexString?.length == 6 || hexString?.length == 7) buffer.write('ff');
        buffer.write(hexString?.replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
    }





    /*
        MAKE GOOGLE EVENT FROM EVENT MODEL
     */

    googleAPI.Event getGoogleEvent()
    {
        googleAPI.Event returnEvent = googleAPI.Event();
        returnEvent.kind = kind;
        returnEvent.etag = etag;
        returnEvent.id = id;
        returnEvent.status = status;
        returnEvent.htmlLink = htmlLink;
        returnEvent.created = created;
        returnEvent.updated = updated;
        returnEvent.summary = summary;
        returnEvent.description = description;
        returnEvent.location = location;

        googleAPI.EventCreator eventCreator = googleAPI.EventCreator();
        eventCreator.displayName = creator?.displayName;
        eventCreator.email = creator?.email;
        eventCreator.id = creator?.id;
        eventCreator.self = creator?.self;

        returnEvent.creator = eventCreator;

        googleAPI.EventOrganizer eventOrganizer = googleAPI.EventOrganizer();
        eventOrganizer.email = organizer?.email;
        eventOrganizer.displayName = organizer?.displayName;
        eventOrganizer.self = organizer?.self;

        googleAPI.EventDateTime eventStart = googleAPI.EventDateTime();
        eventStart.date = start?.date;
        eventStart.dateTime = start?.dateTime;
        eventStart.timeZone = start?.timeZone;

        returnEvent.start = eventStart;

        googleAPI.EventDateTime eventEnd = googleAPI.EventDateTime();
        eventEnd.date = end?.date;
        eventEnd.dateTime = end?.dateTime;
        eventEnd.timeZone = end?.timeZone;

        returnEvent.end = eventEnd;

        returnEvent.endTimeUnspecified = endTimeUnspecified;
        returnEvent.transparency = transparency;
        returnEvent.iCalUID = iCalUid;
        returnEvent.sequence = sequence;

        List<googleAPI.EventAttendee>? eventAttendeeList = <googleAPI.EventAttendee>[];
        for(Attendee singleAttendee in attendees!)
            {
                googleAPI.EventAttendee eventAttendee = googleAPI.EventAttendee();
                eventAttendee.email = singleAttendee.email;
                eventAttendee.self = singleAttendee.self;
                eventAttendee.responseStatus = singleAttendee.responseStatus;
                eventAttendeeList.add(eventAttendee);
            }


        returnEvent.attendees = eventAttendeeList;
        returnEvent.guestsCanInviteOthers = guestsCanInviteOthers;
        returnEvent.privateCopy = privateCopy;

        googleAPI.EventReminders eventReminder = googleAPI.EventReminders();
        eventReminder.useDefault = reminders?.useDefault;

        List<googleAPI.EventReminder> eventOverrides = <googleAPI.EventReminder>[];

        for(Override singleOverride in (reminders?.overrides ?? <Override>[]))
        {
            googleAPI.EventReminder eventReminder = googleAPI.EventReminder();
            eventReminder.method = singleOverride.method;
            eventReminder.minutes = singleOverride.minutes;
            eventOverrides.add(eventReminder);
        }

        eventReminder.overrides = eventOverrides;

        googleAPI.EventSource eventSource = googleAPI.EventSource();
        eventSource.url = source?.url;
        eventSource.title = source?.title;

        returnEvent.source = eventSource;

        return returnEvent;

    }



}
