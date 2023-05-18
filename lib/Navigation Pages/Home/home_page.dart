import 'package:achievio/Models/groupinfo.dart';
import 'package:achievio/User%20Interface/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  List<GroupCard> groupCardsSorted = <GroupCard>[];
  Auth auth = Auth();
  final authUser = FirebaseAuth.instance;

  // Logged in user
  User? user = FirebaseAuth.instance.currentUser;

  // Logged in user data
  UserData currUser = UserData();

  // List of all the users friends
  List<UserData> friends = <UserData>[];
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // create a map for storing fetched group data
  final Map<String, GroupCard> groupCardCache = {};

  void listenToGroups() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('groups')
        .snapshots()
        .listen((snapshot) {
      List<GroupCard> newGroupCards = [];
      // here you'll have to fetch each group's details
      // but remember this code will be triggered for every single change on the groups collection
      for (var groupDoc in snapshot.docs) {
        // if the group is in cache and starred, no need to fetch data again
        if (groupCardCache.containsKey(groupDoc.id) &&
            groupCardCache[groupDoc.id]!.isStarred) {
          newGroupCards.add(groupCardCache[groupDoc.id]!);
        } else {
          // here you can use async code to fetch each group data and update the groupCards list
          fetchGroupData(groupDoc).then((groupCard) {
            groupCardCache[groupDoc.id] = groupCard; // save to cache
            newGroupCards.add(groupCard);
            // replace the old groupCards with the new one
            setState(() {
              groupCards = newGroupCards;
              groupCards.sort((a, b) => a.index.compareTo(b.index));
              // print(groupCards);
            });
          });
        }
      }
    });
  }

  Future<GroupCard> fetchGroupData(QueryDocumentSnapshot groupDoc) async {
    // Replace your old code with async/await style code
    String groupId = groupDoc.id;
    DocumentSnapshot<Map<String, dynamic>> groupSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('groups')
            .doc(groupId)
            .get();
    GroupInfo groupInfo = GroupInfo.fromMap(groupSnapshot.data()!);

    // Fetch the current user's UID
    String currentUserUid = user!.uid;

    // Check if the current user is an admin of the group
    bool isAdmin = groupInfo.admins!.contains(currentUserUid);

    // get the admin's name
    DocumentSnapshot<Map<String, dynamic>> adminSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(groupInfo.admins![0])
            .get();
    String adminName = adminSnapshot.data()!['username'];
    String adminProfilePicture = adminSnapshot.data()!['profilePicture'];

    // Fetch tasks assigned to the user in the group
    QuerySnapshot taskSnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupInfo.groupID)
        .collection('Tasks')
        .get();
    int numbOfTasksAssigned = taskSnapshot.docs.length;

    var currentUserPoints = 0;

    if (!isAdmin) {
      DocumentSnapshot<Map<String, dynamic>> pointsSnapshot =
          await FirebaseFirestore.instance
              .collection('groups')
              .doc(groupInfo.groupID!)
              .collection('users')
              .doc(user!.uid)
              .get();
      if (pointsSnapshot.exists &&
          pointsSnapshot.data()!.containsKey('points')) {
        currentUserPoints = pointsSnapshot.data()!['points'];
      }
    }

    return GroupCard(
      title: groupInfo.title!,
      isStarred: groupInfo.starred!,
      subTitle: groupInfo.description!,
      numbOfTasksAssigned: numbOfTasksAssigned,
      visible: groupInfo.visible!,
      index: groupInfo.index!,
      profilePic: groupInfo.profilePic!,
      isArchived: groupInfo.isArchived!,
      handleStarToggle:
          handleStarToggle, // This would be a function in your code
      uGroupID: groupId,
      uid: groupInfo.groupID!,
      isAdmin: isAdmin,
      points: currentUserPoints,
      adminName: adminName,
      adminProfilePicture: adminProfilePicture,
    );
  }

  @override
  void initState() {
    // add to groupCards
    super.initState();
    requestPermission();
    firebaseCloudMessagingListeners();

    listenToGroups(); // new method to listen to groups
    groupCards.sort((a, b) => a.index.compareTo(b.index));

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

  void requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Permission Denied'),
            content: const Text(
                'We need notification permissions to keep you informed about important updates. Please enable notifications in your device settings.'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      print('User granted permission: ${settings.authorizationStatus}');
    }
  }

  void firebaseCloudMessagingListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(notification.title ?? ''),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(notification.body ?? ''),
                  ],
                ),
              ),
            );
          },
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });

    _firebaseMessaging.getToken().then((deviceToken) {
      print("Firebase Device token: $deviceToken");
    });
  }

  Future<void> handleStarToggle(int index, bool isStarredd, String uid) async {
    var db = FirebaseFirestore.instance;
    var user = FirebaseAuth.instance.currentUser;

    isStarred[index] = isStarredd;

    if (isStarredd) {
      var temp = groupCards.removeAt(index);
      groupCards.insert(0, temp);

      // Update the Firestore document
      var groupRef =
          db.collection('users').doc(user?.uid).collection('groups').doc(uid);
      await groupRef.update({
        'starred': true,
      });
    } else {
      var temp = groupCards.removeAt(index);
      // add the group card after being unstarred to the bottom of the last starred group card
      int insertIndex =
          groupCards.indexWhere((group) => group.isStarred == false);
      if (insertIndex == -1) {
        // All cards are starred, so add at the end
        insertIndex = groupCards.length;
      }

      groupCards.insert(insertIndex, temp);

      // Update the Firestore document
      var groupRef =
          db.collection('users').doc(user?.uid).collection('groups').doc(uid);
      await groupRef.update({
        'starred': false,
      });
    }

    // After completing the async task, call setState
    for (int i = 0; i < groupCards.length; i++) {
      groupCards[i].index = i;
    }

    if (mounted) {
      setState(() {}); // Trigger a UI update
    }

// Update the Firestore document for each group
    for (int i = 0; i < groupCards.length; i++) {
      db
          .collection('users')
          .doc(user?.uid)
          .collection('groups')
          .doc(groupCards[i]
              .uGroupID) // I assumed that uid is a property of GroupCard
          .update({
        'index': i,
      });
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
    return Padding(
      padding: const EdgeInsets.only(right: 30),
      child: Container(
        width: 150,
        height: 70,
        child: Image(
          image: const AssetImage('assets/images/achievio.png'),
          height: MediaQuery.of(context).size.height * 1,
          fit: BoxFit.cover,
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
              padding: const EdgeInsets.only(left: 20, right: 20),
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
