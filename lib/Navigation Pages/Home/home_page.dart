import 'package:achievio/User%20Interface/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Authentication/Authentication Logic/auth_logic.dart';
import '../../Models/userinfo.dart';
import 'ArchivePage/archive_page.dart';
import 'CreateGroupPage/create_group_page.dart';
import 'Widgets/Slivers/list_layout.dart';
import 'Widgets/Slivers/modalsheet_container.dart';
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
  List<GroupCard> groupCardsStarred = <GroupCard>[];
  List<GroupCard> groupCardsSorted = <GroupCard>[];
  Auth auth = Auth();
  final authUser = FirebaseAuth.instance;

  // Logged in user
  User? user = FirebaseAuth.instance.currentUser;

  // Logged in user data
  UserData currUser = UserData();

  // List of all the users friends
  List<UserData> friends = <UserData>[];

  @override
  void initState() {
    // add to groupCards
    super.initState();
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
            profilePic: 'assets/images/Profile_Pic.jpg',
            isArchived: isArchived[i],
            groupCardsStarred: groupCardsStarred,
            handleStarToggle: handleStarToggle,
          ),
        );
      }
    }

    // get the data from the database according to uid
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((value) {
      currUser = UserData.fromMap(value.data()!);

      setState(() {});
    });

    defined = true;

    for (int i = 0; i < groupCards.length; i++) {
      if (groupCards[i].isArchived == false) {
        groupCards[i].visible = true;
      }
    }

    groupCardsSorted.addAll(groupCards);
  }

  void handleStarToggle(int index, bool isStarredd) {
    if (mounted) setState(() {});

    isStarred[index] = isStarredd;

    if (isStarredd) {
      var temp = groupCards.removeAt(index);

      groupCards.insert(0, temp);
    } else {
      var temp = groupCards.removeAt(index);
      // add the group card after being unstarred to the bottom of the last starred group card
      for (int i = 0; i < groupCards.length; i++) {
        if (groupCards[i].isStarred == false) {
          groupCards.insert(i, temp);
          break;
        }
      }
    }

    for (int i = 0; i < groupCards.length; i++) {
      groupCards[i].index = i;
    }
  }

  Future<List> getUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();

    final users = snapshot.docs.map((doc) => doc.data()).toList();
    return users;
  }

  @override
  Widget build(BuildContext context) {
    String? username = currUser.username;
    String? profilePic = currUser.profilePicture;

    // setState(() {
    //   FirebaseFirestore.instance
    //       .collection('users')
    //       .doc(user!.uid)
    //       .get()
    //       .then((value) {
    //     currUser = UserData.fromMap(value.data()!);
    //   });
    // });

    return GestureDetector(
      onTap: () {
        // hide keyboard when tapped outside of the search bar
        FocusScope.of(context).unfocus();
      },

      // swipe right to open drawer
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0.5) {
          _key.currentState!.openDrawer();
        }
      },
      child: SafeArea(
        child: Scaffold(
          key: _key,
          drawer: NavDrawer(
            username: username ?? "",
            profilePic: profilePic ?? "",
            friendsList: friends,
          ),
          // hide the drawer icon
          drawerEnableOpenDragGesture: true,
          // No appbar provided to the Scaffold, only a body with a
          // CustomScrollView.
          backgroundColor: kBackgroundColor,
          body: CustomScrollView(
            // remove splash color
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Upper sliver app bar that is responsible for the app title, user profile picture, and drawer logic
              SliverAppBar(
                leading: Container(),
                flexibleSpace: Column(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            buildHeader(
                              name: username,
                              urlImage: profilePic,
                            ),
                            buildTitle(username: username),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                floating: true,
                expandedHeight: 70,
                toolbarHeight: 70,
                // backgroundColor: const Color.fromARGB(255, 233, 241, 250),
                backgroundColor: Colors.white70,
                elevation: 0,
              ),

              // Lower sliver that is responsible for the search bar and the logic behind it.
              SliverAppBar(
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
                              focusNode: focusNode,
                              controller: controller,
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
                            Navigator.push(
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
              ),

              // A sliver list layout of cards that changes based on the search, archiving, filtering, and sorting.

              ListLayout(groupCardsSorted: groupCardsSorted),
            ],
          ),
        ),
      ),
    );
  }

  Padding buildTitle({required username}) {
    return const Padding(
      padding: EdgeInsets.only(top: 20),
      child: Text(
        "Achievio",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: kTitleColor,
        ),
      ),
    );
  }

  void refreshPage() {
    setState(() {
      groupCardsSorted.clear();

      groupCardsSorted.addAll(groupCards);

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

  Widget buildHeader({required name, required urlImage}) {
    return InkWell(
      child: Column(children: <Widget>[
        if (urlImage != null)
          // CircleAvatar(radius: 60, backgroundImage:),
          GestureDetector(
            onTap: () {
              _key.currentState!.openDrawer();
              FocusScope.of(context).unfocus();
            },
            // on hold preview image
            onLongPress: () {
              // preview a larger image as a hero animation
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: CachedNetworkImage(
                  imageUrl: urlImage,
                  imageBuilder: (context, imageProvider) => Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(
                    color: kGreyColor,
                    strokeWidth: 1.5,
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}
