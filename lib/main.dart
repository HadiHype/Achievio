import 'package:achievio/Navigation%20Pages/Home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Navigation Pages/Activity/activity_page.dart';
import 'Navigation Pages/navigation.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return MaterialApp(
        title: 'Achievio',
        theme: ThemeData(
            indicatorColor: Colors.black,
            fontFamily: GoogleFonts.ptSans().fontFamily,
            primarySwatch: Colors.blue,
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.black,
              selectionColor: Colors.black38,
              selectionHandleColor: Colors.black,
            )),
        debugShowCheckedModeBanner: false,
        onGenerateRoute: ((settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                  builder: (context) => const NavPage(), settings: settings);
            case '/home':
              return MaterialPageRoute(
                  builder: (context) => const HomePage(), settings: settings);
            case '/activity':
              return MaterialPageRoute(
                  builder: (context) => const ActivityPage(),
                  settings: settings);
            default:
              return MaterialPageRoute(
                  builder: (context) => const NavPage(), settings: settings);
          }
        }),
        initialRoute: '/',
        routes: {
          '/': (context) => const NavPage(),
          '/home': (context) => const HomePage(),
          '/activity': (context) => const ActivityPage(),
        });
  }
}
