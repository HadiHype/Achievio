import 'package:achievio/User%20Interface/app_colors.dart';
import 'package:flutter/material.dart';

import '../../User Interface/variables.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Define variables to store the lists for each group
    final todayList = <Widget>[];
    final yesterdayList = <Widget>[];
    final lastWeekList = <Widget>[];
    final thisMonthList = <Widget>[];
    final earlierList = <Widget>[];

    // Loop through each item in the list
    for (int i = 0; i < taskDate.length; i++) {
      // Get the date of the current list item
      final itemDate = DateTime.parse(taskDate[i]);

      // Determine the time difference between the current date and the list item date
      final diff = now.difference(itemDate);

      // Determine the time difference in days
      final daysDiff = diff.inDays;

      // Define a widget that displays the list item
      final listItem = ListTile(
        leading: const CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage("assets/images/Profile_Image.jpg"),
        ),
        title: Text(
          usernames[i],
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          taskStatus[i],
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: Text(
          taskDate[i],
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      );

      // Add the list item to the appropriate list based on time difference
      if (daysDiff == 0) {
        todayList.add(listItem);
      } else if (daysDiff == 1) {
        yesterdayList.add(listItem);
      } else if (daysDiff >= 7 && daysDiff < 14) {
        lastWeekList.add(listItem);
      } else if (daysDiff <= 30) {
        thisMonthList.add(listItem);
      } else {
        earlierList.add(listItem);
      }
    }

    // Define a widget that displays a group of items with a header
    Widget buildGroup(String header, List<Widget> items) {
      return items.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text(header)),
                // const SizedBox(height: 2),
                ...items,
              ],
            )
          : Container();
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const ScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          slivers: [
            SliverAppBar(
              flexibleSpace: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 10, left: 10),
                    child: Text(
                      "Activity",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: kTitleColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    splashColor: kLightSecondaryColor,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashRadius: 20,
                    icon: const Icon(
                      Icons.filter_list_rounded,
                      color: kSecondaryColor,
                      size: 28,
                    ),
                  ),
                ],
              ),
              pinned: true,
              expandedHeight: 55,
              toolbarHeight: 55,
              backgroundColor: Colors.white70,
              elevation: 0,
            ),

            // Build the list with groups of items
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(
                    height: 10,
                  ),
                  buildGroup("Today", todayList),
                  buildGroup("Yesterday", yesterdayList),
                  buildGroup("Last Week", lastWeekList),
                  buildGroup("This Month", thisMonthList),
                  buildGroup("Earlier", earlierList)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
