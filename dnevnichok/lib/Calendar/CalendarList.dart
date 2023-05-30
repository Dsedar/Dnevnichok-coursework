import "package:dnevnichok/Notes/NotesEntry.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import 'package:flutter_slidable/flutter_slidable.dart';
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:scoped_model/scoped_model.dart";
import "package:intl/intl.dart";
import "package:flutter_calendar_carousel/flutter_calendar_carousel.dart";
import "package:flutter_calendar_carousel/classes/event.dart";
import "package:flutter_calendar_carousel/classes/event_list.dart";
import '../Notes/NotesDBWorker.dart';
import '../Notes/NotesModel.dart';


class CalendarList extends StatelessWidget {
  Widget build(BuildContext inContext) {

    print("## AppointmentssList.build()");

    // The list of dates with appointments.
    EventList<Event> markedDateMap = EventList(events: {});
    for (int i = 0; i < notesModel.entityList.length; i++) {
      Note note = notesModel.entityList[i];
      List dateParts = note.noteDate!.split(",");
      DateTime noteDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));//DateTime(2023  , int.parse(dateParts[0]), int.parse(dateParts[1]));
      markedDateMap.add(
          noteDate, Event(date : noteDate,
          icon : Container(

            child: Center(
                child:
                  note.mood == 'awesome'? Icon(FontAwesomeIcons.faceSmileBeam, size: 40, color: Colors.green):
                  note.mood == 'good'? Icon(FontAwesomeIcons.faceSmile, size: 40, color: Colors.lightGreenAccent):
                  note.mood == 'normal'? Icon(FontAwesomeIcons.faceMeh, size: 40, color: Colors.yellow):
                  note.mood == 'bad'? Icon(FontAwesomeIcons.faceFrown, size: 40, color: Colors.orangeAccent):
                  Icon(FontAwesomeIcons.faceAngry, size: 40, color: Colors.red))
            ),
          )
      );
    }

    // Return widget.
    return ScopedModel<NotesModel>(
        model : notesModel,
        child : ScopedModelDescendant<NotesModel>(
            builder : (inContext, inChild, inModel) {
              return Scaffold(
                  // Add appointment.
                  floatingActionButton : FloatingActionButton(
                      backgroundColor: CupertinoColors.systemGrey2,
                      child : Icon(Icons.add, color : Colors.white),
                      onPressed : () async {
                        notesModel.entityBeingEdited = Note();
                        DateTime now = DateTime.now();
                        notesModel.entityBeingEdited.noteDate = "${now.year},${now.month},${now.day}";
                        notesModel.setNoteDate(DateFormat.yMMMMd("en_US").format(now.toLocal()));//setChosenDate
                        //notesModel.setNoteTime(Null as String);
                        notesModel.setStackIndex(1);
                        //Navigator.push(inContext, MaterialPageRoute(builder: (inContext) => NotesEntry()));
                      }
                  ),
                  body : Column(
                      children : [
                        Expanded(
                            child : Container(
                                margin : EdgeInsets.symmetric(horizontal : 10, vertical: 10),
                                child : CalendarCarousel<Event>(
                                    daysTextStyle: TextStyle(
                                      color:  Colors.white
                                    ),
                                    weekdayTextStyle: TextStyle(
                                        color:  Colors.white
                                    ),
                                    weekendTextStyle: TextStyle(
                                        color:  Colors.white
                                    ),
                                    todayButtonColor: CupertinoColors.systemGrey2,
                                    todayBorderColor: CupertinoColors.systemGrey2,

                                    markedDatesMap : markedDateMap,
                                    markedDateIconBuilder: (Event){
                                      return Event.icon;
                                    },
                                    markedDateIconMaxShown: 1,
                                    markedDateCustomShapeBorder: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    onDayPressed : (DateTime inDate, List<Event> inEvents) {
                                      _showAppointments(inDate, inContext);
                                    }
                                ) /* End CalendarCarousel. */
                            ) /* End Container. */
                        ) /* End Expanded. */
                      ] /* End Column.children. */
                  ) /* End Column. */
              ); /* End Scaffold. */
            } /* End ScopedModelDescendant builder(). */
        ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */
  } /* End build(). */

  void _showAppointments(DateTime inDate, BuildContext inContext) async {
    print(
        "## AppointmentsList._showAppointments(): inDate = $inDate (${inDate.year},${inDate.month},${inDate.day})"
    );

    print("## AppointmentsList._showAppointments(): appointmentsModel.entityList.length = "
        "${notesModel.entityList.length}");
    print("## AppointmentsList._showAppointments(): appointmentsModel.entityList = "
        "${notesModel.entityList}");

    showModalBottomSheet(
        context : inContext,
        builder : (BuildContext inContext) {
          return ScopedModel<NotesModel>(
              model : notesModel,
              child : ScopedModelDescendant<NotesModel>(
                  builder : (BuildContext inContext, Widget? inChild, NotesModel inModel) {
                    return Scaffold(
                        body : Container(
                            child : Padding(
                                padding : EdgeInsets.all(10),
                                child : GestureDetector(
                                    child : Column(
                                        children : [
                                          Text(
                                              DateFormat.yMMMMd("en_US").format(inDate.toLocal()),
                                              textAlign : TextAlign.center,
                                              style : TextStyle(color : Theme.of(inContext).colorScheme.secondary, fontSize : 24)
                                          ),
                                          Divider(),
                                          Expanded(
                                              child : ListView.builder(
                                                  itemCount : notesModel.entityList.length,
                                                  itemBuilder : (BuildContext inBuildContext, int inIndex) {
                                                    Note note = notesModel.entityList[inIndex];
                                                    print("## AppointmentsList._showAppointments().ListView.builder(): "
                                                        "appointment = $note");
                                                    // Filter out any appointment that isn't for the specified date.
                                                    if (note.noteDate != "${inDate.year},${inDate.month},${inDate.day}") {
                                                      return Container(height : 0);
                                                    }
                                                    print("## AppointmentsList._showAppointments().ListView.builder(): "
                                                        "INCLUDING appointment = $note");
                                                    // If the appointment has a time, format it for display.
                                                    String noteTime = "";
                                                    if (note.noteTime != null) {
                                                      List timeParts = note.noteTime!.split(",");
                                                      TimeOfDay at = TimeOfDay(
                                                          hour : int.parse(timeParts[0]), minute : int.parse(timeParts[1])
                                                      );
                                                      noteTime = " (${at.format(inContext)})";
                                                    }
                                                    // Return a widget for the appointment since it's for the correct date.
                                                    return Slidable(
                                                        startActionPane: ActionPane(
                                                          motion: const DrawerMotion(),
                                                          extentRatio : .25,
                                                            children: [
                                                              SlidableAction(
                                                                  label : "Delete",
                                                                  backgroundColor : Colors.red,
                                                                  icon : Icons.delete,
                                                                  onPressed : (inContext) => _deleteAppointment(inBuildContext, note)
                                                              ),]
                                                        ),
                                                        child : Container(
                                                            margin : EdgeInsets.only(bottom : 8),
                                                            color : CupertinoColors.systemGrey,
                                                            child : ListTile(
                                                                leading:
                                                                  note.mood == 'awesome'? Icon(FontAwesomeIcons.faceSmileBeam, color: Colors.green, size: 40):
                                                                  note.mood == 'good'? Icon(FontAwesomeIcons.faceSmile, color: Colors.lightGreenAccent, size: 40):
                                                                  note.mood == 'normal'? Icon(FontAwesomeIcons.faceMeh, color: Colors.yellow, size: 40):
                                                                  note.mood == 'bad'? Icon(FontAwesomeIcons.faceFrown, color: Colors.orangeAccent, size: 40):
                                                                  Icon(FontAwesomeIcons.faceAngry, color: Colors.red, size: 40),
                                                                title : Text("${note.title}$noteTime"),
                                                                subtitle : note.content == null ?
                                                                null : Text("${note.content}"),
                                                                // Edit existing appointment.
                                                                onTap : () async { _editAppointment(inContext, note); }
                                                            )
                                                        ),
                                                    ); /* End Slidable. */
                                                  } /* End itemBuilder. */
                                              ) /* End ListView.builder. */
                                          ) /* End Expanded. */
                                        ] /* End Column.children. */
                                    ) /* End Column. */
                                ) /* End GestureDetector. */
                            ) /* End Padding. */
                        ) /* End Container. */
                    ); /* End Scaffold. */
                  } /* End ScopedModel.builder. */
              ) /* End ScopedModelDescendant. */
          ); /* End ScopedModel(). */
        } /* End dialog.builder. */
    ); /* End showModalBottomSheet(). */

  } /* End _showAppointments(). */

  void _editAppointment(BuildContext inContext, Note inNote) async {

    print("## AppointmentsList._editAppointment(): inAppointment = $inNote");

    notesModel.entityBeingEdited = await NotesDBWorker.db.get(inNote.id!);

    if (notesModel.entityBeingEdited.noteDate == null) {
      notesModel.setChosenDate(Null as String);
    } else {
      List dateParts = notesModel.entityBeingEdited.noteDate.split(",");
      DateTime notesDate = DateTime(
          int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2])
      );
      notesModel.setChosenDate(
          DateFormat.yMMMMd("en_US").format(notesDate.toLocal())
      );
    }
    if (notesModel.entityBeingEdited.noteTime == null) {
      notesModel.setNoteTime(Null as String);
    } else {
      List timeParts = notesModel.entityBeingEdited.noteTime.split(",");
      TimeOfDay noteTime = TimeOfDay(
          hour : int.parse(timeParts[0]), minute : int.parse(timeParts[1])
      );
      notesModel.setNoteTime(noteTime.format(inContext));
    }
    notesModel.setStackIndex(1);
    //Navigator.pop(inContext);
    //Navigator.push(inContext, MaterialPageRoute(builder: (inContext) => NotesEntry()));

  } /* End _editAppointment. */


  Future _deleteAppointment(BuildContext inContext, Note inAppointment) async {
    print("## AppointmentsList._deleteAppointment(): inAppointment = $inAppointment");

    return showDialog(
        context : inContext,
        barrierDismissible : false,
        builder : (BuildContext inAlertContext) {
          return AlertDialog(
              title : Text("Delete Note"),
              content : Text("Are you sure you want to delete ${inAppointment.title}?"),
              actions : [
                TextButton(child : Text("Cancel"),
                    onPressed: () {
                      // Just hide dialog.
                      Navigator.of(inAlertContext).pop();
                    }
                ),
                TextButton(child : Text("Delete"),
                    onPressed : () async {
                      // Delete from database, then hide dialog, show SnackBar, then re-load data for the list.
                      await NotesDBWorker.db.delete(inAppointment.id!);
                      Navigator.of(inAlertContext).pop();
                      ScaffoldMessenger.of(inContext).showSnackBar(
                          SnackBar(
                              backgroundColor : Colors.red,
                              duration : Duration(seconds : 2),
                              content : Text("Note deleted")
                          )
                      );
                      // Reload data from database to update list.
                      notesModel.loadData("notes", NotesDBWorker.db);
                    }
                )
              ]
          );
        }
    );

  } /* End _deleteAppointment(). */


} /* End class. */