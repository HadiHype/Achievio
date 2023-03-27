import 'package:achievio/User%20Interface/app_colors.dart';
import 'package:flutter/material.dart';

import '../../User Interface/variables.dart';
import 'Widgets/activity_app_bar.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    List<String> convertedDates = taskDate.map((date) {
      DateTime parsedDate = DateTime.parse(date);
      Duration difference = DateTime.now().difference(parsedDate);

      if (difference.inSeconds < 60) {
        return "${difference.inSeconds} sec";
      } else if (difference.inMinutes < 60) {
        return "${difference.inMinutes} min";
      } else if (difference.inHours < 24) {
        return "${difference.inHours} hr";
      } else if (difference.inDays < 7) {
        return "${difference.inDays} d";
      } else if (difference.inDays < 365 / 12 * 13) {
        return "${(difference.inDays / 7).floor()} w";
      } else if (difference.inDays < 365 * 1.5) {
        return "${(difference.inDays / (365 / 12)).floor()} m";
      } else {
        return "${(difference.inDays / 365).floor()} y";
      }
    }).toList();

    // Define variables to store the lists for each group
    final todayList = <Widget>[];
    final yesterdayList = <Widget>[];
    final thisWeekList = <Widget>[];
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
          radius: 21,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage("assets/images/Profile_Image.jpg"),
        ),
        title: Text(
          usernames[i],
          style: const TextStyle(
            fontSize: 15,
            color: kBlueGreyColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          taskStatus[i],
          style: const TextStyle(
            fontSize: 12,
            color: kSubtitleColor,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: Text(
          convertedDates[i],
          style: const TextStyle(
            fontSize: 12,
            color: kSubtitleColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      );

      // Add the list item to the appropriate list based on time difference
      if (daysDiff == 0) {
        todayList.add(listItem);
      } else if (daysDiff >= 2 && daysDiff < 7) {
        thisWeekList.add(listItem);
      } else if (daysDiff == 1) {
        yesterdayList.add(listItem);
      } else if (daysDiff >= 7 && daysDiff < 14) {
        lastWeekList.add(listItem);
      } else if (daysDiff <= 30 && daysDiff >= 14) {
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
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10),
                  child: Text(
                    header,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: kTitleColor,
                    ),
                  ),
                ),
                ...items,
              ],
            )
          : Container();
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            setState(() {});
          },
          child: CustomScrollView(
            physics: const ScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            slivers: [
              const ActivityAppBar(),

              // Build the list with groups of items
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const SizedBox(
                      height: 10,
                    ),
                    buildGroup("Today", todayList),
                    buildGroup("This Week", thisWeekList),
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
      ),
    );
  }
}
