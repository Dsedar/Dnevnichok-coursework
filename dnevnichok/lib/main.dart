import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import "package:month_year_picker/month_year_picker.dart";
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'Notes/Notes.dart';
import 'Calendar/Calendar.dart';
import 'Statistics/Statistics.dart';
import "dart:io";
import "package:path_provider/path_provider.dart";
import "utils.dart" as utils;
import 'More/More.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  startMeUp() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
    runApp(
        MaterialApp(
          home: MyApp(),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            MonthYearPickerLocalizations.delegate,
          ],
        )
    );
  }
  startMeUp();
}

class MyApp extends StatefulWidget{
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State with TickerProviderStateMixin{
  var _currentPage = 0;
  ThemeData _themeData = ThemeData.dark();
  late ThemeData themeData;

  TabController? _tabController;
  late List <Widget> _tabList = [
    Notes(),
    Calendar(),
    Statistics(),
    More(changeTheme: _changeTheme, themeData: _themeData)
  ];

  @override
  void initState(){
    super.initState();
    _tabController = TabController(length: _tabList.length, vsync: this);
  }

  @override
  void dispose(){
    _tabController!.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: _themeData,
        home : DefaultTabController(
          length: 4,
          child: Scaffold(
            body : TabBarView(
              controller: _tabController,
              children: _tabList,
            ),
            bottomNavigationBar : BottomNavigationBar(
                items : [
                  BottomNavigationBarItem(
                      icon : Icon(Icons.event_note_outlined),
                      label: "Записи",
                  ),
                  BottomNavigationBarItem(
                      icon : Icon(Icons.calendar_month),
                      label : "Календарь"
                  ),
                  BottomNavigationBarItem(
                      icon : Icon(Icons.stacked_bar_chart),
                      label : "Статистика"
                  ),
                  BottomNavigationBarItem(
                      icon : Icon(Icons.more_horiz),
                      label : "Больше"
                  ),
                ],
                currentIndex : _currentPage,
                selectedItemColor: Colors.white,
                unselectedItemColor : Colors.grey,
                onTap : (int inIndex) {
                  setState(() {
                    _currentPage = inIndex;
                    _tabController?.animateTo(_currentPage);
                  });
                }
            )
          )
        )
    );
  }

  void _changeTheme(ThemeData theme) {
    setState(() {
      _themeData = theme;
    });
  }
}




