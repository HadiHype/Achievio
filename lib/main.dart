import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Navigation Pages/navigation.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Justech Informative App',
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
      home: const NavPage(),
    );
  }
}
