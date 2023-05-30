import "package:dnevnichok/Notes/NotesDBWorker.dart";
import "package:dnevnichok/Notes/NotesModel.dart";
import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import '../Notes/NotesEntry.dart';
import 'CalendarList.dart';
import '../Notes/NotesModel.dart' show NotesModel, notesModel;


/// ********************************************************************************************************************
/// The Appointments screen.
/// ********************************************************************************************************************
class Calendar extends StatelessWidget {
  /// Constructor.
  Calendar() {
    print("## Calendar.constructor");

    notesModel.loadData("notes", NotesDBWorker.db);
  } /* End constructor. */

  Widget build(BuildContext inContext) {
    print("## Calendar.build()");

    return ScopedModel<NotesModel>(
        model : notesModel,
        child : ScopedModelDescendant<NotesModel>(
            builder : (BuildContext inContext, Widget? inChild, NotesModel inModel) {
              return IndexedStack(
                  index : inModel.stackIndex,
                  children : [
                    CalendarList(),
                    NotesEntry()
                  ] /* End IndexedStack children. */
              ); /* End IndexedStack. */
            } /* End ScopedModelDescendant builder(). */
        ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */
  } /* End build(). */
} /* End class. */