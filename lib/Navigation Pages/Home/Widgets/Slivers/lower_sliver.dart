import 'package:achievio/Navigation%20Pages/Home/Widgets/card_groups.dart';
import 'package:flutter/material.dart';

import '../../../../User Interface/app_colors.dart';
import '../../../../User Interface/variables.dart';
import '../../ArchivePage/archive_page.dart';
import '../../CreateGroupPage/create_group_page.dart';
import '../custom_text_button.dart';
import '../custom_text_field.dart';
import 'modalsheet_container.dart';

class LowerSliver extends StatefulWidget {
  const LowerSliver({
    super.key,
    required this.focusNode,
    required this.controller,
    required this.groupCardsSorted,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final List<GroupCard> groupCardsSorted;

  @override
  State<LowerSliver> createState() => _LowerSliverState();
}

class _LowerSliverState extends State<LowerSliver> {
  @override
  void initState() {
    refreshPage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: Container(),
      flexibleSpace: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: CustomTextField(
                    focusNode: widget.focusNode,
                    controller: widget.controller,
                    groupCards: groupCards,
                  ),
                ),
              ),
              // filter Icon button
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 10),
                child: IconButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,

                      // increase height
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      builder: (context) {
                        // create a bottom sheet that shows the filter options
                        return const ModelSheetContainer();
                      },
                    ).then(
                      (value) => setState(
                        () {
                          refreshPage();
                        },
                      ),
                    );
                  },
                  splashColor: kLightSecondaryColor,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  splashRadius: 20,
                  icon: const Icon(
                    Icons.filter_list_rounded,
                    color: kBlueGreyColor,
                    size: 28,
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextButton(
                stringText: "Archived Groups",
                onPressed: (() {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArchivePage(),
                    ),
                  );
                }),
                padding: const EdgeInsets.only(left: 10),
              ),
              CustomTextButton(
                stringText: "Create Group",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateGroup(),
                    ),
                  );
                },
                padding: const EdgeInsets.only(right: 10),
              ),
            ],
          ),
        ],
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      expandedHeight: 60,
      toolbarHeight: 106,
      backgroundColor: Colors.white70,
      elevation: 0,
      pinned: true,
    );
  }

  void refreshPage() {
    setState(() {
      widget.groupCardsSorted.clear();

      widget.groupCardsSorted.addAll(groupCards);

      // update state variables here
      if (dropDownValue == 'Alphabetically') {
        widget.groupCardsSorted.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      }

      if (dropDownValue == 'Tasks') {
        widget.groupCardsSorted.sort(
            (a, b) => a.numbOfTasksAssigned.compareTo(b.numbOfTasksAssigned));
      }

      if (dropDownValue == 'Starred') {
        widget.groupCardsSorted.sort(
            (a, b) => b.isStarred.toString().compareTo(a.isStarred.toString()));
      }

      if (dropDownValue2 == 'Starred') {
        for (var element in groupCards) {
          if (element.isStarred) {
            element.visible = true;
          } else {
            element.visible = false;
          }
        }
      } else {
        for (var element in groupCards) {
          element.visible = true;
        }
      }
    });
  }
}
