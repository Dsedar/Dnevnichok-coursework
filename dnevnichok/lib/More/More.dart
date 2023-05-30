import "package:flutter/material.dart";
import "package:flutter/material.dart";
import 'package:settings_ui/settings_ui.dart';
import "package:flutter/cupertino.dart";

class More extends StatefulWidget {
  final Function(ThemeData) changeTheme;
  final ThemeData themeData;

  const More({Key? key, required this.changeTheme, required this.themeData}) : super(key: key);

  @override
  State createState() => _More(changeTheme: changeTheme, themeData: themeData);
/* End constructor. */
}

class _More extends State {
  final Function(ThemeData) changeTheme;
  final ThemeData themeData;
  _More({required this.changeTheme, required this.themeData});
  late bool _isDarkModeEnabled = (themeData == ThemeData.dark()? false: true);
  //bool _isDarkModeEnabled = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkModeEnabled? ThemeData.dark(): ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Больше'),
        ),
        body: SettingsList(
          sections: [
            SettingsSection(
              title: Text('Общие'),
              tiles: [
                SettingsTile(
                  title: Text('Язык'),
                  value: Text('Русский'),
                  leading: Icon(Icons.language),
                  onPressed: (BuildContext context) {},
                ),
                SettingsTile.switchTile(
                  title: Text('Темная тема'),
                  initialValue: _isDarkModeEnabled,
                  leading: Icon(Icons.color_lens),
                  onToggle: (bool value) {
                    setState(() {
                      _isDarkModeEnabled = value;
                      if (_isDarkModeEnabled) {
                        changeTheme(ThemeData.dark());
                      } else {
                        changeTheme(ThemeData.light());
                      }
                    });
                  },
                ),
              ],
            ),
            SettingsSection(
              title: Text('Уведомления'),
              tiles: [
                SettingsTile.switchTile(
                  title: Text('Присылать напоминания'),
                  leading: Icon(Icons.notifications),
                  initialValue: false,
                  onToggle: (bool value) {},
                ),
                SettingsTile(
                  title: Text('Время напоминаний'),
                  value: Text('20:00'),
                  leading: Icon(Icons.access_time_rounded),
                  onPressed: (BuildContext context) {},
                ),
              ],
            ),
            SettingsSection(
              title: Text('Приватность'),
              tiles: [
                SettingsTile(
                  title: Text('PIN - код'),
                  value: Text('Выкл'),
                  leading: Icon(Icons.lock_outline),
                  onPressed: (BuildContext context) {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}