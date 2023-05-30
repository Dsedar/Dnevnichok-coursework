import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "../Notes/NotesDBWorker.dart";
import "../Notes/NotesModel.dart" show Note, NotesModel, notesModel;
import "package:intl/intl.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:flutter/cupertino.dart";
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:pie_chart/pie_chart.dart';

class Statistics extends StatefulWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  State createState() => _Statistics();
/* End constructor. */
}

class _Statistics extends State {
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
  Map<String, double> _chartsDataMap = {};
  List<String> moodList = ['awesome', 'good', 'normal', 'bad', 'awful'];
  List<String> foundNotesMoodsDates = [];

  void _runFilter(String date) {
    List<Map<String, dynamic>>? results = [];
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

  Map<String, double> _foundNotesMoodsLength(List<String> moodList) {
    Map<String, double> moodCountMap = {};
    moodList.forEach((mood) {
      double count = 0;
      if (mood == null) {
        _foundNotes.forEach((note) {
          if (note['mood'] != null) {
            count++;
          }
        });
      } else {
        _foundNotes.where((note) {
          return note['mood'] == mood;
        }).forEach((note) {
          count++;
        });
      }
      moodCountMap[mood] = count;
    });
    // Refresh the UI
    setState(() {
      _chartsDataMap = moodCountMap;
      print('## _foundNotesMoodLength setState() ${_chartsDataMap}');
    });
    return moodCountMap;
  }


  @override
  Widget build(BuildContext inContext) {
    final ButtonStyle appTextStyle = TextButton.styleFrom(
      foregroundColor: Theme.of(inContext).colorScheme.onPrimary,
    );
    _allNotes = notesModel.entityList.map((note) => note.toMap()).toList();
    print('_allNotes = $_allNotes');
    _foundNotes = _allNotes.cast<Map<String, dynamic>>();
    _runFilter(date.month.toString());
    final double sum = _foundNotesMoodsLength(moodList).values.reduce((acc, val) => acc + val);
    final Map<String, double> dataMap = _chartsDataMap;

    List<MoodData> moodData = _foundNotes.where((note) => note['mood'] != null).map((note) => MoodData(note['mood'], note['noteDate'])).toList();

    print("## _Statistics.build()");
    final colorList = <Color>[
      Colors.green,
      Colors.lightGreenAccent,
      Colors.yellow,
      Colors.orangeAccent,
      Colors.red
    ];

    int mapMoodValue(String moodValue) {
      switch (moodValue) {
        case 'awesome':
          return 5;
        case 'good':
          return 4;
        case 'normal':
          return 3;
        case 'bad':
          return 2;
        default:
          return 1;
      }
    }
    Color getPointColor(MoodData mood) {
      switch (mood.moodValue) {
        case 'awesome':
          return Colors.green;
        case 'good':
          return Colors.lightGreenAccent;
        case 'normal':
          return Colors.yellow;
        case 'bad':
          return Colors.orangeAccent;
        default:
          return Colors.red;
      }
    }
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
                body: Container(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: _foundNotes.isNotEmpty
                        ? ListView(
                            children: <Widget>[
                              SfCartesianChart(
                                title: ChartTitle(text: 'График настроения'),
                                primaryXAxis: CategoryAxis(),
                                series: <LineSeries<MoodData, String>>[
                                  LineSeries<MoodData, String>(
                                    dataSource: moodData,
                                    xValueMapper: (MoodData mood, _) => mood.date,
                                    yValueMapper: (MoodData mood, _) => mapMoodValue(mood.moodValue),
                                      pointColorMapper: (MoodData mood, _) => getPointColor(mood),
                                      dataLabelSettings: DataLabelSettings(isVisible: true)
                                  ),
                                ],
                              ),
                              Divider(),
                              PieChart(
                              dataMap: dataMap,
                              chartType: ChartType.ring,
                              baseChartColor: Colors.grey[50]!.withOpacity(0.15),
                              colorList: colorList,
                              chartValuesOptions: ChartValuesOptions(
                                showChartValuesInPercentage: true,
                              ),
                              totalValue: sum,
                            )]
                        )
                        : Center(
                          child: Text(
                            'No results found',
                            style: TextStyle(fontSize: 24),
                      ),
                    ),
                  )
              );
            }
        )
    );
  }
}

class MoodData {
  final String date;
  final String moodValue;

  MoodData(this.moodValue, this.date);
}