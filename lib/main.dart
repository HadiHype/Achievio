import 'package:achievio/Authentication/Authentication%20Screen/login_page.dart';
import 'package:achievio/Authentication/Authentication%20Screen/signup_page.dart';
import 'package:achievio/Navigation%20Pages/Home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'Authentication/Authentication Logic/auth_logic.dart';
import 'Navigation Pages/Activity/activity_page.dart';
import 'Navigation Pages/navigation.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final Auth auth = Auth();
  final bool isLogged = await auth.isLogged();

  final MyApp myApp = MyApp(
    route: isLogged ? '/nav' : '/login',
  );

  runApp(myApp);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.route}) : super(key: key);
  final String route;

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
        ),
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: ((settings) {
        switch (settings.name) {
          case '/nav':
            return MaterialPageRoute(
                builder: (context) => const NavPage(), settings: settings);
          case '/home':
            return MaterialPageRoute(
                builder: (context) => const HomePage(), settings: settings);
          case '/activity':
            return MaterialPageRoute(
                builder: (context) => const ActivityPage(), settings: settings);
          case '/login':
            return MaterialPageRoute(
                builder: (context) => const LoginScreen(), settings: settings);
          case '/register':
            return MaterialPageRoute(
                builder: (context) => const SignUpScreen(), settings: settings);
          // default:
          //   return MaterialPageRoute(
          //       builder: (context) => const NavPage(), settings: settings);
        }
      }),
      // check if user is logged in and change initial route
      routes: {
        '/nav': (context) => const NavPage(),
        '/home': (context) => const HomePage(),
        '/activity': (context) => const ActivityPage(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const SignUpScreen(),
      },
      initialRoute: route,
    );
  }
}
