import 'package:achievio/User%20Interface/app_colors.dart';
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
  });

  final String title;
  bool isStarred;
  final String subTitle;
  final int numbOfTasksAssigned;

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
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
                        Text(
                          widget.title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
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
                              });
                            },
                            child: Icon(
                              widget.isStarred ? Icons.star : Icons.star_border,
                              color: widget.isStarred
                                  ? Colors.amber
                                  : kBlueGreyColor,
                              size: 21,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          GestureDetector(
                            child: const Icon(
                              Icons.more_horiz,
                              color: kBlueGreyColor,
                              size: 21,
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
                        borderRadius: BorderRadius.all(Radius.circular(5)),
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
    );
  }
}
