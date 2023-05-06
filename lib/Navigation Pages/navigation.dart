import 'package:achievio/User%20Interface/app_colors.dart';
import 'package:flutter/material.dart';
import 'Activity/activity_page.dart';
import 'Home/home_page.dart';

class NavPage extends StatefulWidget {
  const NavPage({Key? key}) : super(key: key);

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  List pages = [
    const HomePage(),
    const ActivityPage(),
  ];

  int currentIndex = 0;
  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 8.5,
          unselectedFontSize: 0,
          onTap: onTap,
          currentIndex: currentIndex,
          backgroundColor: Colors.white,
          selectedItemColor: kBlueGreyColor,
          unselectedItemColor: kLightBlueGreyColor,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 8,
          items: [
            BottomNavigationBarItem(
              label: "Home",
              icon: currentIndex == 0
                  ? const Icon(Icons.home, size: 31)
                  : const Icon(Icons.home_outlined, size: 31),
            ),
            BottomNavigationBarItem(
              label: "Alerts",
              icon: currentIndex == 1
                  ? const Icon(Icons.notifications, size: 31)
                  : const Icon(Icons.notifications_none_outlined, size: 31),
            ),
          ],
        ),
      ),
    );
  }
}
