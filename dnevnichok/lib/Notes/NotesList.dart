import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:scoped_model/scoped_model.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "NotesDBWorker.dart";
import "NotesModel.dart" show Note, NotesModel, notesModel;
import "package:flutter/cupertino.dart";
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


/// ****************************************************************************
/// The Notes List sub-screen.
/// ****************************************************************************
class NotesList extends StatefulWidget {
  const NotesList({Key? key}) : super(key: key);

  @override
  State createState() => _NotesList();
}

class _NotesList extends State {
  DateTime date = DateTime.now();
  DateTime time = DateTime.now();
  DateTime dateTime = DateTime.now();

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) =>
            Container(
              height: 216,
              padding: const EdgeInsets.only(top: 6.0),
              // The Bottom margin is provided to align the popup above the system
              // navigation bar.
              margin: EdgeInsets.only(
                bottom: MediaQuery
                    .of(context)
                    .viewInsets
                    .bottom,
              ),
              // Provide a background color for the popup.
              color: CupertinoColors.systemBackground.resolveFrom(context),
              // Use a SafeArea widget to avoid system overlaps.
              child: SafeArea(
                top: false,
                child: child,
              ),
            )
    );
  }


  List _allNotes = [];
  List<Map<String, dynamic>> _foundNotes = [];


  /*@override
  initState() {
    _allNotes = notesModel.entityList.map((note) => note.toMap()).toList();
    print('_allNotes = $_allNotes');
    _foundNotes = _allNotes.cast<Map<String, dynamic>>();
    _runFilter(date.month.toString());

    super.initState();
  }*/

  void _runFilter(String date) {
    List<Map<String, dynamic>>? results = [];
    print(date);
    print(_allNotes);
    if (date == null) {
      results = _allNotes.cast<Map<String, dynamic>>();
    } else {
      results = _allNotes.where((note) {
        String dateString = note['noteDate'];
        DateTime noteDate = DateFormat('yyyy,M,d').parse(dateString);
        print('_runFilter noteDate = $noteDate');
        return noteDate.month.toString().contains(date);
      })
          .cast<Map<String, dynamic>>()
          .toList();

    }

    // Refresh the UI
    setState(() {
      _foundNotes = results!;
      print('## _runFilter setState() ${_foundNotes}');
    });
  }

  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  Widget build(BuildContext inContext) {
    final ButtonStyle appTextStyle = TextButton.styleFrom(
      foregroundColor: Theme.of(inContext).colorScheme.onPrimary,
    );
    _allNotes = notesModel.entityList.map((note) => note.toMap()).toList();
    print('_allNotes = $_allNotes');
    _foundNotes = _allNotes.cast<Map<String, dynamic>>();
    _runFilter(date.month.toString());

    print("## NotesList.build()");
    // Return widget.
    return ScopedModel<NotesModel>(
        model : notesModel,
        child : ScopedModelDescendant<NotesModel>(
            builder : (BuildContext inContext, Widget? inChild, NotesModel inModel) {
              return Scaffold(
                  appBar : AppBar(
                      centerTitle: true,
                      title : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Icon(Icons.note),
                            IconButton(onPressed: (){setState(() {
                              date = new DateTime(date.year ,date.month - 1, date.day);
                              _runFilter(date.month.toString());
                            });} /*minusOneMonth*/, icon: Icon(Icons.arrow_back_ios)),
                            TextButton(onPressed: () => _showDialog(
                              CupertinoDatePicker(
                                initialDateTime: date,
                                mode: CupertinoDatePickerMode.date,
                                use24hFormat: true,
                                // This is called when the user changes the date.
                                onDateTimeChanged: (DateTime newDate) {
                                  setState(() {
                                    date = newDate;
                                    _runFilter(date.month.toString())
                                    ;}
                                  );
                                },
                              ),
                            ) /*ChooseMonth*/, style: appTextStyle, child: Text(DateFormat.MMMM('en_US').format(date)),),
                            IconButton(onPressed: (){setState(() {
                              date = new DateTime(date.year ,date.month + 1, date.day);
                              _runFilter(date.month.toString());
                            });} /*plusOneMonth*/, icon: Icon(Icons.arrow_forward_ios)),
                            IconButton(onPressed: (){} /*searchNote*/, icon: Icon(Icons.find_in_page_outlined))
                          ]
                      )
                  ),
                  // Add note.
                  floatingActionButton : FloatingActionButton(
                      backgroundColor: CupertinoColors.systemGrey2,
                      child : Icon(CupertinoIcons.add, color: Colors.white,),
                      onPressed : () async {
                        notesModel.entityBeingEdited = Note();
                        //notesModel.setColor(null);
                        notesModel.setStackIndex(1);
                      }
                  ),
                  body : _foundNotes.isNotEmpty?
                      ListView.builder(
                      //itemCount : notesModel.entityList.length,
                        itemCount: _foundNotes.length,
                        itemBuilder : (BuildContext inBuildContext, int inIndex) {
                          Map<String, dynamic> note = _foundNotes[inIndex];
                          Color color = CupertinoColors.systemGrey2;
                          return Container(
                            padding : EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child : Slidable(
                                startActionPane: ActionPane(
                                  motion: const DrawerMotion(),
                                  extentRatio : .25,
                                  children: [
                                    SlidableAction(
                                      label : "Delete",
                                      backgroundColor : Colors.red,
                                      icon : Icons.delete,
                                      onPressed: (inContext) => _deleteNote(inContext, note),
                                    ),
                                  ],
                                ),
                                child : Card(
                                    elevation : 4,
                                    color : color,
                                    child : ListTile(
                                            leading:
                                              note['mood'] == 'awesome'? Icon(FontAwesomeIcons.faceSmileBeam, color: Colors.green, size: 40):
                                              note['mood'] == 'good'? Icon(FontAwesomeIcons.faceSmile, color: Colors.lightGreenAccent, size: 40):
                                              note['mood'] == 'normal'? Icon(FontAwesomeIcons.faceMeh, color: Colors.yellow, size: 40):
                                              note['mood'] == 'bad'? Icon(FontAwesomeIcons.faceFrown, color: Colors.orangeAccent, size: 40):
                                              Icon(FontAwesomeIcons.faceAngry, color: Colors.red, size: 40),
                                            title : Text("${note['title']}"),
                                            subtitle : Text("${note['content']}"),
                                            trailing: Text("${note['noteDate']}"),
                                            // Edit existing note.
                                            onTap : () async {
                                              notesModel.entityBeingEdited = await NotesDBWorker.db.get(note['id']);
                                              notesModel.setMood(notesModel.entityBeingEdited.mood);
                                              notesModel.setStackIndex(1);
                                            }
                                        )
                                    )
                            )
                        );
                      }
                  )
                     : const Text('No results found', style: TextStyle(fontSize: 24),),
              );
            }
        )
    );
  }




  /// Show a dialog requesting delete confirmation.
  ///
  /// @param  inContext The BuildContext of the parent Widget.
  /// @param  inNote    The note (potentially) being deleted.
  /// @return           Future.
  Future _deleteNote(BuildContext inContext, Map<String, dynamic> inNote) async {

    print("## NotestList._deleteNote(): inNote = $inNote");

    return showDialog(
        context : inContext,
        barrierDismissible : false,
        builder : (BuildContext inAlertContext) {
          return AlertDialog(
              title : Text("Delete Note"),
              //content : Text("Are you sure you want to delete ${inNote.title}?"),
              content : Text("Are you sure you want to delete ${inNote['title']}?"),
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
                      await NotesDBWorker.db.delete(inNote['id']!);
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

  } /* End _deleteNote(). */


} /* End class. */