import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uwall/screens/main_page.dart';
import 'package:theme_provider/theme_provider.dart';

void main() => runApp(UWall());

class UWall extends StatelessWidget {
  final List<AppTheme> _appTheme = [
    AppTheme(
        id: 'light',
        data: ThemeData(
            primaryColor: Colors.white,
            accentColor: Colors.grey[400],
            canvasColor: Colors.transparent,
            brightness: Brightness.light,
            textTheme: TextTheme(display1: TextStyle(color: Colors.black87)),
            iconTheme: IconThemeData(color: Colors.black87),
            dialogBackgroundColor: Colors.white),
        description: 'Light Theme'),
    AppTheme(
        id: 'dark',
        data: ThemeData(
            primaryColor: Colors.grey[850],
            accentColor: Colors.grey[350],
            canvasColor: Colors.transparent,
            brightness: Brightness.dark,
            textTheme: TextTheme(display1: TextStyle(color: Colors.white)),
            iconTheme: IconThemeData(color: Colors.white),
            dialogBackgroundColor: Colors.grey[850]),
        description: 'Dark Grey Theme'),
    AppTheme(
        id: 'black',
        data: ThemeData(
            primaryColor: Colors.black,
            accentColor: Colors.black12,
            canvasColor: Colors.transparent,
            brightness: Brightness.dark,
            textTheme: TextTheme(display1: TextStyle(color: Colors.white)),
            iconTheme: IconThemeData(color: Colors.white),
            dialogBackgroundColor: Colors.grey[850]),
        description: 'Black Theme')
  ];

  @override
  Widget build(BuildContext context) {
    // set status bar color
    SystemChrome.setEnabledSystemUIOverlays([]);

    return ThemeProvider(
        saveThemesOnChange: true,
        loadThemeOnInit: true,
        defaultThemeId: 'light',
        themes: _appTheme,
        child: MaterialApp(
          title: 'UWall',
          home: ThemeConsumer(
            child: MainPage(),
          ),
          debugShowCheckedModeBanner: false,
        ));
  }
}
