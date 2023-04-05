import 'package:achievio/Navigation%20Pages/navigation.dart';
import 'package:flutter/material.dart';

import '../../../User Interface/app_colors.dart';
import '../../../User Interface/variables.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

// In this page, we will display all the archived groups of the user.

class _ArchivePageState extends State<ArchivePage> {
  @override
  void initState() {
    // We will set the visibility of all the archived groups to true.
    for (int i = 0; i < groupCardsArchived.length; i++) {
      if (groupCardsArchived[i].visible == false) {
        groupCardsArchived[i].visible = true;
        groupCardsArchived[i].isArchived = true;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Archive',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          elevation: 1,
          backgroundColor: kTertiaryColor,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              // TODO: Change this to appeal to the user's device (Apple or Android)
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              // Navigate to the home page, we do this by popping the current page for the previous page to reload and display the changes.
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NavPage()),
              );
            },
          ),
        ),
        backgroundColor: Colors.white,
        body: Center(
          // This is where the list of archived groups will be displayed.
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return groupCardsArchived[index];
            },
            itemCount: groupCardsArchived.length,
          ),
        ),
      ),
    );
  }
}
