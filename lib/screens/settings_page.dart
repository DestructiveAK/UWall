import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    final _textColor = Theme.of(context).textTheme.display1.color;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 2.0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Settings',
          style: TextStyle(
              color: _textColor,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
              leading: null,
              title: Text(
                'Theme',
                style: TextStyle(
                    color: _textColor,
                    fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Change App Theme',
                style: TextStyle(
                  color: _textColor,
                ),
              ),
              onTap: _showDialog),
              /*ListTile(
                leading: null,
                title: Text(
                  'Advanced Theming',
                  style: TextStyle(
                    color: _textColor,
                    fontWeight: FontWeight.bold
                  ),),
                  subtitle: Text(
                    'Customize app theme',
                    style: TextStyle(
                      color: _textColor,
                    ),
                  ),
                  onTap: null,
              )*/
        ],
      ),
    );
  }

  _showDialog() {
    var dialogOptionFontSize = 20.0;
    var themeId = ThemeProvider.themeOf(context).id;
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)
            ),
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            title: Text(
              'Change Theme',
              style: TextStyle(
                  color: Theme.of(context).textTheme.display1.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0
                  ),
            ),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  'Light',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.display1.color,
                      fontSize: dialogOptionFontSize,
                      fontWeight: themeId == 'light' 
                      ? FontWeight.bold
                      : FontWeight.normal,)
                ),
                onPressed: () {
                  ThemeProvider.controllerOf(context).setTheme('light');
                  Navigator.of(context).pop();
                },
              ),
              SimpleDialogOption(
                child: Text(
                  'Dark',
                  key: Key('dark'),
                  style: TextStyle(
                      color: Theme.of(context).textTheme.display1.color,
                      fontSize: dialogOptionFontSize,
                      fontWeight: themeId == 'dark' 
                      ? FontWeight.bold
                      : FontWeight.normal),
                ),
                onPressed: () {
                  ThemeProvider.controllerOf(context).setTheme('dark');
                  Navigator.of(context).pop();
                },
              ),
              SimpleDialogOption(
                child: Text(
                  'Black',
                  key: Key('black'),
                  style: TextStyle(
                      color: Theme.of(context).textTheme.display1.color,
                      fontSize: dialogOptionFontSize,
                      fontWeight: themeId == 'black' 
                      ? FontWeight.bold
                      : FontWeight.normal),
                ),
                onPressed: () {
                  ThemeProvider.controllerOf(context).setTheme('black');
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
