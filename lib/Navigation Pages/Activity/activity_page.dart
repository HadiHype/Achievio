import 'package:achievio/User%20Interface/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Models/userinfo.dart';
import '../../User Interface/variables.dart';
import 'Widgets/activity_app_bar.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String listShow = "Notifications";

  final authUser = FirebaseAuth.instance;

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

    return SafeArea(
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: RefreshIndicator(
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
              // sliverappbar to change the view of the sliverlist

              SliverAppBar(
                pinned: true,
                expandedHeight: 45,
                toolbarHeight: 45,
                backgroundColor: Colors.white70,
                elevation: 0,
                flexibleSpace: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            listShow = "Friend Requests";
                            print(listShow);
                          });
                        },
                        child: Text(
                          "Friend Requests",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: listShow == "Friend Requests"
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: listShow == "Friend Requests"
                                ? kTitleColor
                                : kBlueGreyColor,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            listShow = "Notifications";
                            print(listShow);
                          });
                        },
                        child: Text(
                          "Notifications",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: listShow == "Notifications"
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: listShow == "Notifications"
                                ? kTitleColor
                                : kBlueGreyColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Build the list with groups of items

              listShow == "Notifications"
                  ? SliverList(
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
                    )
                  : FutureBuilder<dynamic>(
                      future: getFriendRequests(),
                      builder: (BuildContext context, snapshot) {
                        if (snapshot.data == null) {
                          return const SliverToBoxAdapter(
                            child: Center(
                              child: Text("No Friend Requests"),
                            ),
                          );
                        }

                        if (snapshot.hasData) {
                          // get the users from the friend requests list and display them in the sliverlist
                          // Answer:

                          return SliverList(
                              delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: CachedNetworkImage(
                                        imageUrl: snapshot.data?[index]
                                            ["profilePicture"],
                                        height: 45,
                                        width: 45,
                                        fit: BoxFit.cover),
                                  ),
                                  title: Text(
                                    snapshot.data?[index]["username"],
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Container(
                                        height: 27.5,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.grey[300],
                                        ),
                                        child: TextButton(
                                          child: const Text(
                                            "Reject",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 10,
                                            ),
                                          ),
                                          onPressed: () {
                                            // remove the user from the friend requests list of the current user
                                            FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(FirebaseAuth
                                                    .instance.currentUser!.uid)
                                                .update({
                                              "friendRequestReceived":
                                                  FieldValue.arrayRemove([
                                                snapshot.data?[index]["uid"]
                                              ])
                                            });

                                            // remove the current user from the friend requests list of the user
                                            FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(snapshot.data?[index]
                                                    ["uid"])
                                                .update({
                                              "friendRequestSent":
                                                  FieldValue.arrayRemove([
                                                FirebaseAuth
                                                    .instance.currentUser!.uid
                                              ])

                                              // refresh the page
                                            }).then((value) => setState(() {}));
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Container(
                                        height: 27.5,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.grey[300],
                                        ),
                                        child: TextButton(
                                          child: const Text(
                                            "Accept",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 10,
                                            ),
                                          ),
                                          onPressed: () {
                                            // add the user to the friends list of the current user
                                            FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(FirebaseAuth
                                                    .instance.currentUser!.uid)
                                                .update({
                                              "friends": FieldValue.arrayUnion([
                                                snapshot.data?[index]["uid"]
                                              ])
                                            });

                                            // add the current user to the friends list of the user
                                            FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(snapshot.data?[index]
                                                    ["uid"])
                                                .update({
                                              "friends": FieldValue.arrayUnion([
                                                FirebaseAuth
                                                    .instance.currentUser!.uid
                                              ])
                                            });

                                            // remove the user from the friend requests list of the current user
                                            FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(FirebaseAuth
                                                    .instance.currentUser!.uid)
                                                .update({
                                              "friendRequestReceived":
                                                  FieldValue.arrayRemove([
                                                snapshot.data?[index]["uid"]
                                              ])
                                            });

                                            // remove the current user from the friend requests list of the user
                                            FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(snapshot.data?[index]
                                                    ["uid"])
                                                .update({
                                              "friendRequestSent":
                                                  FieldValue.arrayRemove([
                                                FirebaseAuth
                                                    .instance.currentUser!.uid
                                              ])
                                            }).then((value) => setState(() {}));
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: null,
                                ),
                              );
                            },
                            childCount: snapshot.data?.length,
                          ));
                        } else {
                          return const SliverToBoxAdapter(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  getFriendRequests() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      // return the list of users from the friend requests list
      var friendRequests = value.data()!["friendRequestReceived"];

      // return all users from the friend requests list as snapshot
      var friendRequestsSnapshot = FirebaseFirestore.instance
          .collection("users")
          .where(FieldPath.documentId, whereIn: friendRequests)
          .get();

      return friendRequestsSnapshot.then((value) {
        // return the list of users from the friend requests list
        print(value.docs.map((e) => e.data()).toList());
        return value.docs.map((e) => e.data()).toList();
      });
    });
  }
}
