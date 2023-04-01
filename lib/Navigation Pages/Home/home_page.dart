import 'package:achievio/User%20Interface/app_colors.dart';
import 'package:flutter/material.dart';
import 'CreateGroupPage/create_group_page.dart';
import 'Widgets/card_groups.dart';
import '../../User Interface/variables.dart';

import 'Widgets/custom_text_button.dart';
import 'Widgets/custom_text_field.dart';
import 'Widgets/nav_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FocusNode focusNode = FocusNode();
  TextEditingController controller = TextEditingController();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  List<GroupCard> groupCardsSorted = <GroupCard>[]; // List of group cards

  @override
  void initState() {
    // add to groupCards
    if (defined == false) {
      for (int i = 0; i < titles.length; i++) {
        groupCards.add(
          GroupCard(
            title: titles[i],
            isStarred: isStarred[i],
            subTitle: subTitles[i],
            numbOfTasksAssigned: tasksAssigned[i],
            visible: true,
            groupCards: groupCards,
            index: i,
          ),
        );
      }

      defined = true;
    }

    groupCardsSorted.addAll(groupCards);
    refreshPage();
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState

    super.setState(fn);
  }

  void _addItem() {
    setState(() {
      groupCards.add(GroupCard(
        title: "New Group",
        isStarred: false,
        subTitle: "New Subtitle",
        numbOfTasksAssigned: 0,
        visible: true,
        groupCards: groupCards,
        index: groupCards.length,
      ));
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      // swipe right to open drawer
      onHorizontalDragEnd: (details) {
        FocusScope.of(context).unfocus();
        if (details.primaryVelocity! > 0) {
          _key.currentState!.openDrawer();
        }
      },
      child: SafeArea(
        child: Scaffold(
          key: _key,
          drawer: const NavDrawer(),
          // hide the drawer icon
          drawerEnableOpenDragGesture: false,
          // No appbar provided to the Scaffold, only a body with a
          // CustomScrollView.
          backgroundColor: kBackgroundColor,
          body: StatefulBuilder(
            builder: (context, setState) => CustomScrollView(
              // remove splash color
              physics: const ScrollPhysics(),
              slivers: [
                // Add the app bar to the CustomScrollView.
                SliverAppBar(
                  leading: Container(),
                  flexibleSpace: upperSliver(),
                  floating: true,
                  expandedHeight: 70,
                  toolbarHeight: 70,
                  // backgroundColor: const Color.fromARGB(255, 233, 241, 250),
                  backgroundColor: Colors.white70,
                  elevation: 0,
                ),

                SliverAppBar(
                  leading: Container(),
                  flexibleSpace: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Container(
                              width: 335,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              child: CustomTextField(
                                focusNode: focusNode,
                                controller: controller,
                                groupCards: groupCards,
                              ),
                            ),
                          ),
                          // filter Icon button
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: IconButton(
                              // TODO: create filter page according to tasks or alphabetically
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
                                    return SizedBox(
                                      height: 200,
                                      child: Column(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(top: 10),
                                            child: Text(
                                              "Filter",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: kTitleColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Divider(
                                            color: kBlueGreyColor,
                                            thickness: 1,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: const [
                                              Text(
                                                "Sort by",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: kTitleColor,
                                                ),
                                              ),
                                              Text(
                                                "Filter by",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: kTitleColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              test(),
                                              StatefulBuilder(
                                                builder: (context, setState) =>
                                                    DropdownButton<String>(
                                                  value: dropDownValue2,
                                                  items: <String>[
                                                    'All',
                                                    'Starred',
                                                  ].map((String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                  onChanged: (val) {
                                                    setState(() {
                                                      dropDownValue2 = val!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
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
                          const CustomTextButton(
                            stringText: "Archived Groups",
                            // TODO: create archive page
                            onPressed: null,
                            padding: EdgeInsets.only(left: 10),
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
                            padding: EdgeInsets.only(right: 10),
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
                ),

                // create a sliver list of cards that changes based on the search
                SliverLayoutBuilder(
                  builder: (context, constraint) => SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        if (groupCards[index].visible &&
                            dropDownValue == 'default') {
                          return groupCards[index];
                        } else if (groupCards[index].visible &&
                            dropDownValue != 'default') {
                          return groupCardsSorted[index];
                        } else {
                          return const SizedBox();
                        }
                      },
                      childCount: groupCards.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void refreshPage() {
    setState(() {
      // update state variables here
      if (dropDownValue == 'Alphabetically') {
        groupCardsSorted.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      }

      if (dropDownValue == 'Tasks') {
        groupCardsSorted.sort(
            (a, b) => a.numbOfTasksAssigned.compareTo(b.numbOfTasksAssigned));
      }

      if (dropDownValue == 'Starred') {
        groupCardsSorted.sort(
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

  StatefulBuilder test() {
    return StatefulBuilder(
      builder: (context, setState) => DropdownButton<String>(
        value: dropDownValue,
        items: <String>[
          'default',
          'Alphabetically',
          'Tasks',
          'Starred',
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            dropDownValue = val!;
          });
        },
      ),
    );
  }

  Column upperSliver() {
    return Column(
      children: [
        Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _key.currentState!.openDrawer();
                    FocusScope.of(context).unfocus();
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 20, top: 20, right: 20),
                    // TODO: Make the profile image clickable and show a drawer
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Image(
                        image: AssetImage("assets/images/Profile_Image.jpg"),
                        width: 42.5,
                        height: 42.5,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "Achievio",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: kTitleColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
