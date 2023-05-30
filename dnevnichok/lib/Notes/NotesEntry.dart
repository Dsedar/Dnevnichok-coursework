import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:scoped_model/scoped_model.dart";
import "NotesDBWorker.dart";
import "NotesModel.dart" show Note, NotesModel, notesModel;
import "../utils.dart" as utils;
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class NotesEntry extends StatelessWidget {
  /// Controllers for TextFields.
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController = TextEditingController();

  // Key for form.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  NotesEntry() {
    print("## NotesEntry.constructor");
    // Attach event listeners to controllers to capture entries in model.
    _titleEditingController.addListener(() {
      notesModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _contentEditingController.addListener(() {
      notesModel.entityBeingEdited.content = _contentEditingController.text;
    });

  } /* End constructor. */

  Widget build(BuildContext inContext) {
    print("## NotesEntry.build()");

    // Set value of controllers.
    if (notesModel.entityBeingEdited != null) {
      _titleEditingController.text = notesModel.entityBeingEdited.title.toString();
      _contentEditingController.text = notesModel.entityBeingEdited.content.toString();
    }

    // Return widget.
    return ScopedModel(
        model : notesModel,
        child : ScopedModelDescendant<NotesModel>(
            builder : (BuildContext inContext, Widget? inChild, NotesModel inModel) {
              return Scaffold(
                  bottomNavigationBar : Padding(
                      padding : EdgeInsets.symmetric(vertical : 0, horizontal : 10),
                      child : Row(
                          children : [
                            TextButton(
                                child : Text("Cancel"),
                                onPressed : () {
                                  // Hide soft keyboard.
                                  FocusScope.of(inContext).requestFocus(FocusNode());
                                  // Go back to the list view.
                                  inModel.setStackIndex(0);
                                }
                            ),
                            Spacer(),
                            TextButton(
                                child : Text("Save"),
                                onPressed : () { _save(inContext, notesModel); }
                            )
                          ]
                      )
                  ),
                  body : Form(
                      key : _formKey,
                      child : ListView(
                          children : [
                            // Title.
                            ListTile(
                                leading : Icon(Icons.title),
                                title : TextFormField(
                                    decoration : InputDecoration(hintText : "Title"),
                                    controller : _titleEditingController,
                                    validator : (inValue) {
                                      if (inValue?.length == 0) { return "Please enter a title"; }
                                      return null;
                                    }
                                )
                            ),
                            // Content.
                            ListTile(
                                leading : Icon(Icons.content_paste),
                                title : TextFormField(
                                    keyboardType : TextInputType.multiline, maxLines : 5,
                                    decoration : InputDecoration(hintText : "Content"),
                                    controller : _contentEditingController,
                                    validator : (inValue) {
                                      if (inValue?.length == 0) { return "Please enter content"; }
                                      return null;
                                    }
                                )
                            ),
                            // Note mood.
                            ListTile(
                                //leading : Icon(Icons.color_lens),
                                title : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    verticalDirection: VerticalDirection.down,
                                    children : [
                                      IconButton(
                                          icon: Icon(FontAwesomeIcons.faceSmileBeam, color: Colors.green, size: 40,),
                                          onPressed : () {
                                            notesModel.entityBeingEdited.mood = "awesome";
                                            notesModel.setMood("awesome");
                                          }
                                      ),
                                      Spacer(),
                                      IconButton(
                                          icon: FaIcon(FontAwesomeIcons.faceSmile, color: Colors.lightGreenAccent, size: 40,),
                                          onPressed : () {
                                            notesModel.entityBeingEdited.mood = "good";
                                            notesModel.setMood("good");
                                          }
                                      ),
                                      Spacer(),
                                      IconButton(
                                          icon: FaIcon(FontAwesomeIcons.faceMeh, color: Colors.yellow, size: 40,),
                                          onPressed : () {
                                            notesModel.entityBeingEdited.mood = "normal";
                                            notesModel.setMood("normal");
                                          }
                                      ),
                                      Spacer(),
                                      IconButton(
                                          icon: FaIcon(FontAwesomeIcons.faceFrown, color: Colors.orangeAccent, size: 40,),
                                          onPressed : () {
                                            notesModel.entityBeingEdited.mood = "bad";
                                            notesModel.setMood("bad");
                                          }
                                      ),
                                      Spacer(),
                                      IconButton(
                                          icon: Icon(FontAwesomeIcons.faceAngry, color: Colors.red, size: 40,),
                                          onPressed : () {
                                            notesModel.entityBeingEdited.mood = "awful";
                                            notesModel.setMood("awful");
                                          }
                                      ),
                                    ]
                                )
                            ),
                            ListTile(
                                leading : Icon(Icons.today),
                                title : Text("Date"),
                                subtitle : Text(notesModel.noteDate == null ? "" : notesModel.noteDate!),
                                trailing : IconButton(
                                    icon : Icon(Icons.edit),
                                    color : Colors.blue,
                                    onPressed : () => _selectDate(inContext)/*async {
                                      // Request a date from the user.  If one is returned, store it.
                                      String chosenDate = await utils.selectDate(
                                          inContext, notesModel, notesModel.entityBeingEdited.noteDate
                                      );
                                      if (chosenDate != null) {
                                        notesModel.entityBeingEdited.noteDate = chosenDate;
                                      }
                                    }*/
                                )
                            ),
                            // Appointment Time.
                            ListTile(
                                leading : Icon(Icons.alarm),
                                title : Text("Time"),
                                subtitle : Text(notesModel.noteTime == null ? "" : notesModel.noteTime!),
                                trailing : IconButton(
                                    icon : Icon(Icons.edit),
                                    color : Colors.blue,
                                    onPressed : () => _selectTime(inContext)
                                )
                            )
                          ] /* End Column children. */
                      ) /* End ListView. */
                  ) /* End Form. */
              ); /* End Scaffold. */
            } /* End ScopedModelDescendant builder(). */
        ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */
  } /* End build(). */

  /// Save this contact to the database.
  ///
  /// @param inContext The BuildContext of the parent widget.
  /// @param inModel   The NotesModel.
  void _save(BuildContext inContext, NotesModel inModel) async {

    print("## NotesEntry._save()");

    // Abort if form isn't valid.
    if (!_formKey.currentState!.validate()) { return; }

    // Creating a new note.
    if (inModel.entityBeingEdited.id == null) {
      print("## NotesEntry._save(): Creating: ${inModel.entityBeingEdited}");
      await NotesDBWorker.db.create(notesModel.entityBeingEdited);
      // Updating an existing note.
    } else {
      print("## NotesEntry._save(): Updating: ${inModel.entityBeingEdited}");
      await NotesDBWorker.db.update(notesModel.entityBeingEdited);

    }
    // Reload data from database to update list.
    notesModel.loadData("notes", NotesDBWorker.db);
    // Go back to the list view.
    inModel.setStackIndex(0);
    // Show SnackBar.
    ScaffoldMessenger.of(inContext).showSnackBar(
        SnackBar(
            backgroundColor : Colors.green,
            duration : Duration(seconds : 2),
            content : Text("Note saved")
        )
    );
  }

  Future _selectTime(BuildContext inContext) async {

    // Default to right now, assuming we're adding an appointment.
    TimeOfDay initialTime = TimeOfDay.now();
    print("## NotesEntry._selectTime(): DateTime: ${initialTime}");

    // If editing an appointment, set the initialTime to the current apptTime, if any.
    if (notesModel.entityBeingEdited.noteTime != null) {
      List timeParts = notesModel.entityBeingEdited.noteTime.split(",");
      // Create a DateTime using the hours, minutes and a/p from the apptTime.
      initialTime = TimeOfDay(hour : int.parse(timeParts[0]), minute : int.parse(timeParts[1]));
    }

    // Now request the time.
    TimeOfDay? picked = await showTimePicker(context : inContext, initialTime : initialTime);

    // If they didn't cancel, update it on the appointment being edited as well as the apptTime field in the model so
    // it shows on the screen.
    if (picked != null) {
      notesModel.entityBeingEdited.noteTime = "${picked.hour},${picked.minute}";
      notesModel.setNoteTime(picked.format(inContext));
    }

  }

  Future _selectDate(BuildContext inContext) async {

    // Default to right now, assuming we're adding an appointment.
    DateTime initialDate = DateTime.now();
    print("## NotesEntry._selectTime(): DateTime: ${initialDate}");
    // If editing an appointment, set the initialTime to the current apptTime, if any.
    if (notesModel.entityBeingEdited.noteDate != null) {
      List dateParts = notesModel.entityBeingEdited.noteDate.split(",");
      // Create a DateTime using the hours, minutes and a/p from the apptTime.
      initialDate = DateTime(/*2023*/int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
    }

    // Now request the time.
    DateTime? picked = await showDatePicker(context : inContext, initialDate : initialDate, firstDate: DateTime(2018), lastDate: DateTime(2025));
    String formattedPicked = DateFormat.yMMMMd('en_US').format(picked!.toLocal());
    // If they didn't cancel, update it on the appointment being edited as well as the apptTime field in the model so
    // it shows on the screen.
    if (picked != null) {
      notesModel.entityBeingEdited.noteDate = "${picked.year},${picked.month},${picked.day}";
      notesModel.setNoteDate(formattedPicked);
    }

  }
} /* End class. */