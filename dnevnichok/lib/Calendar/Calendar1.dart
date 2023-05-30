import "package:dnevnichok/Notes/Notes.dart";
import 'package:flutter/material.dart';
import "package:scoped_model/scoped_model.dart";
import 'package:syncfusion_flutter_calendar/calendar.dart';
import "../Notes/NotesDBWorker.dart";
import "../Notes/NotesList.dart";
import "../Notes/NotesEntry.dart";
import "../Notes/NotesModel.dart" show Note, NotesModel, notesModel;

/// The app which hosts the home page which contains the calendar on it.
class CalendarApp extends StatelessWidget {
  late NoteDataSource _notes;
  late List<Note> _dataSource;

  CalendarApp(){
    notesModel.loadData("notes", NotesDBWorker.db);
    print("##CalendarApp.constructor");
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<NotesModel>(
        model : notesModel,
        child : ScopedModelDescendant<NotesModel>(
        builder : (BuildContext inContext, Widget? inChild, NotesModel inModel){
          return Scaffold(
              body: SfCalendar(
                view: CalendarView.month,
                dataSource: NoteDataSource(_dataSource),
                // by default the month appointment display mode set as Indicator, we can
                // change the display mode as appointment using the appointment display
                // mode property
                monthViewSettings: const MonthViewSettings(
                    appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
              ));

        },
        ),
    );
  }

}

/// An object to set the appointment collection data source to calendar, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class NoteDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  NoteDataSource(List<Note> source) {
    var notes = source;
  }
}