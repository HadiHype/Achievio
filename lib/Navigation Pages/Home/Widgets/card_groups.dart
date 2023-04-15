import 'package:achievio/User%20Interface/app_colors.dart';
import 'package:achievio/User%20Interface/variables.dart';
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
    required this.groupCards,
    required this.index,
    required this.profilePic,
    required this.isArchived,
  });

  String title;
  bool isStarred;
  String subTitle;
  int numbOfTasksAssigned;
  bool visible;
  final List<GroupCard> groupCards;
  int index;
  String profilePic;
  bool isArchived;

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  @override
  Widget build(BuildContext context) {
    // TODO: Let the card be clickable and navigate to the group page
    int isPressed = 0;

    return widget.visible == true
        ? GestureDetector(
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
                                      image: AssetImage(
                                        widget.profilePic,
                                      ),
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
                                  GestureDetector(
                                    // on tap change icon to filled star for specific index
                                    onTap: () {
                                      setState(() {
                                        widget.isStarred = !widget.isStarred;
                                        isStarred[widget.index] =
                                            widget.isStarred;
                                        // put the group card after being starred to the top of the list
                                        if (widget.isStarred) {
                                          var temp = widget.groupCards
                                              .removeAt(widget.index);

                                          widget.groupCards.insert(0, temp);
                                        } else {
                                          var temp = widget.groupCards
                                              .removeAt(widget.index);
                                          // add the group card after being unstarred to the bottom of the last starred group card
                                          for (int i = 0;
                                              i < widget.groupCards.length;
                                              i++) {
                                            if (widget
                                                    .groupCards[i].isStarred ==
                                                false) {
                                              widget.groupCards.insert(i, temp);
                                              break;
                                            }
                                          }
                                        }

                                        // update the index of the group cards
                                        for (int i = 0;
                                            i < widget.groupCards.length;
                                            i++) {
                                          widget.groupCards[i].index = i;
                                        }
                                      });
                                    },

                                    child: Icon(
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
                                                  widget.groupCards,
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
                            Container(
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
                            ),
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
    groupCards,
    int index,
    int isPressed,
    context,
  ) {
    setState(() {
      // groupCardsArchived.add(widget.groupCards[widget.index]);
      GroupCard groupCardstemp;

      if (!widget.isArchived) {
        widget.visible = false;
        groupCardstemp = groupCards.removeAt(widget.index);
        groupCardsArchived.add(groupCardstemp);
        groupCardstemp.isArchived = true;
      } else {
        widget.visible = false;
        groupCardstemp = groupCardsArchived[groupCardsArchived.indexOf(widget)];
        groupCardsArchived.removeWhere((element) => element == widget);
        groupCardstemp.isArchived = false;
        groupCards.insert(widget.index, groupCardstemp);
      }

      for (int i = 0; i < groupCards.length; i++) {
        groupCards[i].index = i;
      }

      // create a toast message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          content:
              // text widget and textbutton to undo
              Row(
            children: [
              const Text("Group archived"),
              const SizedBox(
                width: 10,
              ),
              TextButton(
                onPressed: () {
                  setState(
                    () {
                      isPressed++;

                      if (isPressed > 1) {
                        return;
                      } else {
                        if (!widget.visible && widget.isArchived) {
                          widget.visible = true;
                          groupCardstemp = groupCardsArchived[
                              groupCardsArchived.indexOf(widget)];
                          groupCardsArchived
                              .removeWhere((element) => element == widget);
                          groupCardstemp.isArchived = false;
                          groupCards.insert(widget.index, groupCardstemp);
                        } else if (!widget.visible && !widget.isArchived) {
                          widget.visible = true;
                          groupCards.removeAt(widget.index);
                          groupCardsArchived.add(groupCardstemp);
                        }
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      }
                    },
                  );
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
    });
  }
}
