import "dart:async";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:scoped_model/scoped_model.dart";
import "../utils.dart" as utils;
import "../Notes/NotesDBWorker.dart";
import "../Notes/NotesModel.dart" show NotesModel, notesModel;


/// ********************************************************************************************************************
/// The Appointments Entry sub-screen.
/// ********************************************************************************************************************
class CalendarEntry extends StatelessWidget {


  /// Controllers for TextFields.
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController = TextEditingController();


  // Key for form.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  /// Constructor.
  CalendarEntry() {

    print("## AppointmentsEntry.constructor");

    // Attach event listeners to controllers to capture entries in model.
    _titleEditingController.addListener(() {
      notesModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _descriptionEditingController.addListener(() {
      notesModel.entityBeingEdited.content = _descriptionEditingController.text;
    });

  } /* End constructor. */


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  Widget build(BuildContext inContext) {

    print("## AppointmentsEntry.build()");

    // Set value of controllers.
    if (notesModel.entityBeingEdited != null) {
      _titleEditingController.text = notesModel.entityBeingEdited.title;
      _descriptionEditingController.text = notesModel.entityBeingEdited.content;
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
                                leading : Icon(Icons.subject),
                                title : TextFormField(
                                    decoration : InputDecoration(hintText : "Title"),
                                    controller : _titleEditingController,
                                    validator : (String? inValue) {
                                      if (inValue!.length == 0) { return "Please enter a title"; }
                                      return null;
                                    }
                                )
                            ),
                            // Description.
                            ListTile(
                                leading : Icon(Icons.content_paste),
                                title : TextFormField(
                                    keyboardType : TextInputType.multiline, maxLines : 8,
                                    decoration : InputDecoration(hintText : "Content"),
                                    controller : _descriptionEditingController,
                                    validator : (inValue) {
                                      if (inValue!.isEmpty) { return "Please enter content"; }
                                      return null;
                                    }
                                )
                            ),
                            ListTile(
                                leading : Icon(Icons.color_lens),
                                title : Row(
                                    children : [
                                      GestureDetector(
                                          child : Container(
                                              decoration : ShapeDecoration(shape :
                                              Border.all(color : Colors.red, width : 18) +
                                                  Border.all(
                                                      width : 6,
                                                      color : notesModel.mood == "red" ? Colors.red : Theme.of(inContext).canvasColor
                                                  )
                                              )
                                          ),
                                          onTap : () {
                                            notesModel.entityBeingEdited.color = "red";
                                            notesModel.setMood("red");
                                          }
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                          child : Container(
                                              decoration : ShapeDecoration(shape :
                                              Border.all(color : Colors.green, width : 18) +
                                                  Border.all(
                                                      width : 6,
                                                      color : notesModel.mood == "green" ? Colors.green : Theme.of(inContext).canvasColor
                                                  )
                                              )
                                          ),
                                          onTap : () {
                                            notesModel.entityBeingEdited.color = "green";
                                            notesModel.setMood("green");
                                          }
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                          child : Container(
                                              decoration : ShapeDecoration(shape :
                                              Border.all(color : Colors.blue, width : 18) +
                                                  Border.all(
                                                      width : 6,
                                                      color : notesModel.mood == "blue" ? Colors.blue : Theme.of(inContext).canvasColor
                                                  )
                                              )
                                          ),
                                          onTap : () {
                                            notesModel.entityBeingEdited.color = "blue";
                                            notesModel.setMood("blue");
                                          }
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                          child : Container(
                                              decoration : ShapeDecoration(shape :
                                              Border.all(color : Colors.yellow, width : 18) +
                                                  Border.all(
                                                      width : 6,
                                                      color : notesModel.mood == "yellow" ? Colors.yellow : Theme.of(inContext).canvasColor
                                                  )
                                              )
                                          ),
                                          onTap : () {
                                            notesModel.entityBeingEdited.color = "yellow";
                                            notesModel.setMood("yellow");
                                          }
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                          child : Container(
                                              decoration : ShapeDecoration(shape :
                                              Border.all(color : Colors.grey, width : 18) +
                                                  Border.all(
                                                      width : 6,
                                                      color : notesModel.mood == "grey" ? Colors.grey : Theme.of(inContext).canvasColor
                                                  )
                                              )
                                          ),
                                          onTap : () {
                                            notesModel.entityBeingEdited.color = "grey";
                                            notesModel.setMood("grey");
                                          }
                                      ),
                                    ]
                                )
                            ),
                            // Appointment Date.
                            ListTile(
                                leading : Icon(Icons.today),
                                title : Text("Date"),
                                subtitle : Text(notesModel.noteDate == null ? "" : notesModel.noteDate!),
                                trailing : IconButton(
                                    icon : Icon(Icons.edit),
                                    color : Colors.blue,
                                    onPressed : () => _selectDate(inContext),
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

  /// Function for handling taps on the edit icon for apptDate.
  ///
  /// @param inContext  The BuildContext of the parent Widget.
  /// @return           Future.
  Future _selectTime(BuildContext inContext) async {

    // Default to right now, assuming we're adding an appointment.
    TimeOfDay initialTime = TimeOfDay.now();

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

  } /* End _selectTime(). */


  /// Save this contact to the database.
  ///
  /// @param inContext The BuildContext of the parent widget.
  /// @param inModel   The AppointmentsModel.
  void _save(BuildContext inContext, NotesModel inModel) async {

    print("## AppointmentsEntry._save()");

    // Abort if form isn't valid.
    if (!_formKey.currentState!.validate()) { return; }

    // Creating a new appointment.
    if (inModel.entityBeingEdited.id == null) {

      print("## AppointmentsEntry._save(): Creating: ${inModel.entityBeingEdited}");
      await NotesDBWorker.db.create(notesModel.entityBeingEdited);

      // Updating an existing appointment.
    } else {

      print("## AppointmentsEntry._save(): Updating: ${inModel.entityBeingEdited}");
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
            content : Text("Appointment saved")
        )
    );

  } /* End _save(). */


} /* End class. */