import "dart:ui";
import "../BaseModel.dart";


/// A class representing this PIM entity type.
class Note {
  /// The fields this entity type contains.
  int? id;
  String? title;
  String? content;
  String? mood;
  String? noteDate; // YYYY,MM,DD
  String? noteTime; // HH,MM

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'mood': mood,
      'noteDate': noteDate,
      'noteTime': noteTime,
    };
  }
  //Note(this.id, this.title, this.content, this.mood,this.noteDate, this.noteTime);
  /// Just for debugging, so we get something useful in the console.
  String toString() {
    return "{id: $id, title: $title, content: $content, color: $mood, noteDate: $noteDate, noteDate: $noteTime}";
  }
} /* End class. */


/// ****************************************************************************
/// The model backing this entity type's views.
/// ****************************************************************************
class NotesModel extends BaseModel {
  /// The color.  Needed to be able to display what the user picks in the Text widget on the entry screen.
  String? mood;
  String? noteTime;
  String? noteDate;
  List<Note>? notes;
  /// For display of the color chosen by the user.
  ///
  /// @param inColor The color.
  void setMood(String inMood) {
    print("## NotesModel.setMood(): inMood = $inMood");
    mood = inMood;
    notifyListeners();
  }

  void setNoteTime(String inNoteTime) {
    print("## NotesModel.setNoteTime(): inNoteTime = $inNoteTime");
    noteTime = inNoteTime;
    notifyListeners();
  }

  void setNoteDate(String inNoteDate) {
    print("## NotesModel.inNoteDate(): inNoteDate = $inNoteDate");
    noteDate = inNoteDate;
    notifyListeners();
  }
} /* End class. */


// The one and only instance of this model.
NotesModel notesModel = NotesModel();