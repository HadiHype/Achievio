import 'package:achievio/Navigation%20Pages/Group/admin_task_page.dart';
import 'package:achievio/Navigation%20Pages/Group/group_page.dart';
import 'package:achievio/User%20Interface/app_colors.dart';
import 'package:achievio/User%20Interface/variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'stacked_avatars.dart';

// ignore: must_be_immutable
class GroupCard extends StatefulWidget {
  GroupCard({
    super.key,
    required this.title,
    required this.isStarred,
    required this.subTitle,
    required this.numbOfTasksAssigned,
    required this.visible,
    required this.index,
    required this.profilePic,
    required this.isArchived,
    required this.handleStarToggle,
    required this.uGroupID,
    required this.uid,
    required this.isAdmin,
    required this.points,
  });

  String title;
  bool isStarred;
  String subTitle;
  int numbOfTasksAssigned;
  bool visible;
  int index;
  String profilePic;
  bool isArchived;
  final Future<void> Function(int index, bool isStarred, String uid)
      handleStarToggle;
  String uid;
  String uGroupID;
  bool isAdmin;
  int points;

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  bool _isOperationOngoing = false;

  @override
  Widget build(BuildContext context) {
    // TODO: Let the card be clickable and navigate to the group page
    int isPressed = 0;

    return widget.visible == true
        ? GestureDetector(
            onTap: () {
              // navigate to group page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    if (widget.isAdmin) {
                      return AdminTasksPage(
                          uid: widget.uid, groupPicture: widget.profilePic);
                    } else {
                      return UserTaskPage(
                        uid: widget.uid,
                        groupPicture: widget.profilePic,
                        groupTitle: widget.title,
                        groupDescription: widget.subTitle,
                      );
                    }
                  },
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.white70,
                  padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    child: Image(
                                      image: NetworkImage(widget.profilePic),
                                      width: 36,
                                      height: 36,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                const StackedAvatars(),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    splashRadius: 1,
                                    onPressed: _isOperationOngoing
                                        ? null
                                        : () async {
                                            setState(() {
                                              _isOperationOngoing = true;
                                            });
                                            await widget.handleStarToggle(
                                                widget.index,
                                                !widget.isStarred,
                                                widget.uGroupID);
                                            setState(() {
                                              widget.isStarred =
                                                  !widget.isStarred;
                                              _isOperationOngoing = false;
                                            });
                                          },
                                    icon: Icon(
                                      widget.isStarred
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: widget.isStarred
                                          ? Colors.amber
                                          : kBlueGreyColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  GestureDetector(
                                    // open pop up menu
                                    onTapDown: (details) async {
                                      final offset = details.globalPosition;
                                      showMenu(
                                        context: context,
                                        position: RelativeRect.fromLTRB(
                                          offset.dx,
                                          offset.dy,
                                          MediaQuery.of(context).size.width -
                                              offset.dx,
                                          MediaQuery.of(context).size.height -
                                              offset.dy,
                                        ),
                                        items: [
                                          // TODO: Add functionality to edit group by taking user to edit group page (Only when firebase is ready)
                                          const PopupMenuItem(
                                            child: Text("Edit"),
                                          ),
                                          PopupMenuItem(
                                            onTap: () {
                                              _archiveGroup(
                                                  // widget.groupCards,
                                                  widget.index,
                                                  isPressed,
                                                  context);
                                            },
                                            child: !widget.isArchived
                                                ? const Text("Archive")
                                                : const Text("Unarchive"),
                                          ),
                                        ],
                                      );
                                    },
                                    child: const Icon(
                                      Icons.more_horiz,
                                      color: kBlueGreyColor,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 3,
                        ),
                        SizedBox(
                          width: 240,
                          height: 50,
                          child: Text(
                            widget.subTitle,
                            style: const TextStyle(
                              fontSize: 10.5,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 2,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            !widget.isAdmin
                                ? Container(
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      color: Color(0xBD569DC1),
                                    ),
                                    padding: const EdgeInsets.only(
                                        top: 3, bottom: 3, left: 4, right: 4),
                                    child: Text(
                                      "${widget.numbOfTasksAssigned} tasks assigned to you",
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Container(),
                            !widget.isAdmin
                                ? CircleAvatar(
                                    backgroundColor: Color(0xBD569DC1),
                                    child: Container(
                                      child: Text(
                                        widget.points.toString(),
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        : Container();
  }

  _archiveGroup(
    int index,
    int isPressed,
    context,
  ) async {
    // Mark this function as async
    GroupCard groupCardstemp;

    var db = FirebaseFirestore.instance;
    var user = FirebaseAuth.instance.currentUser;

    if (!widget.isArchived) {
      print("Archive");
      widget.visible = false;
      groupCardstemp = groupCards.removeAt(widget.index);
      groupCardsArchived.add(groupCardstemp);
      groupCardstemp.isArchived = true;

      // Update the Firestore document
      var groupRef = db
          .collection('users')
          .doc(user?.uid)
          .collection('groups')
          .doc(widget.uGroupID);
      await groupRef.update({
        'isArchived': true,
      });
    } else {
      widget.visible = false;
      groupCardstemp = groupCardsArchived[groupCardsArchived.indexOf(widget)];
      groupCardsArchived.removeWhere((element) => element == widget);
      groupCardstemp.isArchived = false;
      groupCards.insert(groupCards.length, groupCardstemp);

      // Update the Firestore document
      var groupRef = db
          .collection('users')
          .doc(user?.uid)
          .collection('groups')
          .doc(widget.uGroupID);
      await groupRef.update({
        'isArchived': false,
      });
    }

    // After completing the async task, call setState
    setState(() {
      for (int i = 0; i < groupCards.length; i++) {
        groupCards[i].index = i;
        // Update the Firestore document for each group
        db
            .collection('users')
            .doc(user?.uid)
            .collection('groups')
            .doc(groupCards[i].uGroupID)
            .update({
          'index': i,
        });
      }

      for (int i = 0; i < groupCardsArchived.length; i++) {
        groupCardsArchived[i].index = i;
        // Update the Firestore document for each archived group
        db
            .collection('users')
            .doc(user?.uid)
            .collection('groups')
            .doc(groupCardsArchived[i].uGroupID)
            .update({
          'index': i,
        });
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        content: Row(
          children: [
            const Text("Group archived"),
            const SizedBox(
              width: 10,
            ),
            TextButton(
              onPressed: () async {
                isPressed++;

                if (isPressed > 1) {
                  return;
                } else {
                  if (!widget.visible && widget.isArchived) {
                    widget.visible = true;
                    groupCardstemp =
                        groupCardsArchived[groupCardsArchived.indexOf(widget)];
                    groupCardsArchived
                        .removeWhere((element) => element == widget);
                    groupCardstemp.isArchived = false;
                    groupCards.insert(groupCards.length, groupCardstemp);

                    // Update the Firestore document
                    var groupRef = db
                        .collection('users')
                        .doc(user?.uid)
                        .collection('groups')
                        .doc(widget.uGroupID);
                    await groupRef.update({
                      'isArchived': false,
                    });
                  } else if (!widget.visible && !widget.isArchived) {
                    widget.visible = true;
                    groupCards.removeAt(widget.index);
                    groupCardsArchived.add(groupCardstemp);
                    var groupRef = db
                        .collection('users')
                        .doc(user?.uid)
                        .collection('groups')
                        .doc(widget.uGroupID);
                    await groupRef.update({
                      'isArchived': true,
                    });
                  }
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();

                  // After completing the async task, call setState to update UI
                  setState(() {
                    for (int i = 0; i < groupCards.length; i++) {
                      groupCards[i].index = i;
                      // Update the Firestore document for each group
                      db
                          .collection('users')
                          .doc(user?.uid)
                          .collection('groups')
                          .doc(groupCards[i].uGroupID)
                          .update({
                        'index': i,
                      });
                    }

                    for (int i = 0; i < groupCardsArchived.length; i++) {
                      groupCardsArchived[i].index = i;
                      // Update the Firestore document for each archived group
                      db
                          .collection('users')
                          .doc(user?.uid)
                          .collection('groups')
                          .doc(groupCardsArchived[i].uGroupID)
                          .update({
                        'index': i,
                      });
                    }
                  });
                }
              },
              child: const Text(
                "Undo",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
