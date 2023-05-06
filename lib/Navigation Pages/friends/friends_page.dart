import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Models/userinfo.dart';
import '../../User Interface/app_colors.dart';

class Friends extends StatefulWidget {
  const Friends({required this.friendList, super.key});

  final List<UserData> friendList;

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  TextEditingController searchController = TextEditingController();
  TextEditingController addFriendController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  FocusNode addFriendFocusNode = FocusNode();
  String searchQuery = '';
  String searchQueryAddFriend = '';
  String output = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            'Friends',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          elevation: 1,
          backgroundColor: kTertiaryColor,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // open a dialog box to add a friend by username
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (dialogContext) => ScaffoldMessenger(
                child: Builder(
                  builder: (context) => Scaffold(
                    backgroundColor: Colors.transparent,
                    body: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).pop(),
                      child: GestureDetector(
                        onTap: () {},
                        child: AlertDialog(
                          title: const Text(
                            "Add Friend",
                            style: TextStyle(
                              color: kTitleColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 40,
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextField(
                                  controller: addFriendController,
                                  focusNode: addFriendFocusNode,
                                  autofocus: true,
                                  onTapOutside: (event) =>
                                      searchFocusNode.unfocus(),
                                  onChanged: (value) => setState(() {
                                    searchQueryAddFriend = value;
                                  }),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.white,
                                    ),
                                    hintText: "add friend by username",
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                output,
                                style: const TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  // two buttons to cancel or add friend
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        searchQueryAddFriend = '';
                                        Navigator.pop(context);
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                kTertiaryColor),
                                      ),
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        // add friend to firebase by sending a request first
                                        final authUser = FirebaseAuth.instance;

                                        // search for the user in the database
                                        var user = FirebaseFirestore.instance
                                            .collection("users")
                                            .where("username",
                                                isEqualTo: searchQueryAddFriend)
                                            .get()
                                            .then((value) {
                                          if (value.docs.isNotEmpty) {
                                            // add the user to the current user's friend list if the user is not already in the list
                                            if (widget.friendList.indexWhere(
                                                        (element) =>
                                                            element.uid ==
                                                            value.docs[0]
                                                                    .data()[
                                                                "uid"]) ==
                                                    -1 &&
                                                value.docs[0].id !=
                                                    authUser.currentUser!.uid) {
                                              FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(
                                                      authUser.currentUser!.uid)
                                                  .update({
                                                "friends":
                                                    FieldValue.arrayUnion(
                                                        [value.docs[0].id])
                                              });

                                              // add the current user to the friend's friend list
                                              FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(value.docs[0].id)
                                                  .update({
                                                "friendsRequest":
                                                    FieldValue.arrayUnion([
                                                  authUser.currentUser!.uid
                                                ])
                                              });

                                              // add the current user to the friend's friend list
                                              UserData tempUser =
                                                  UserData.fromMap(
                                                      value.docs[0].data());

                                              widget.friendList.add(tempUser);
                                            } else {
                                              // show an error message if the user is already in the friend list
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'User already exists'),
                                                  duration:
                                                      Duration(seconds: 2),
                                                  backgroundColor:
                                                      kTertiaryColor,
                                                ),
                                              );
                                            }
                                          } else {
                                            // show an error message if the user is not found with the given username
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text('User not found'),
                                                duration: Duration(seconds: 2),
                                                backgroundColor: kTertiaryColor,
                                              ),
                                            );
                                          }
                                        });
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                kTertiaryColor),
                                      ),
                                      child: const Text(
                                        "Add Friend",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          elevation: 2,
          backgroundColor: kTertiaryColor,
          child: const Text(
            "Add Friend",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Column(
          children: [
            // Create a search bar
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      onTapOutside: (event) => searchFocusNode.unfocus(),
                      onChanged: (value) => setState(() {
                        searchQuery = value;
                      }),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.friendList.length,
                itemBuilder: (context, index) {
                  if (searchQuery.isNotEmpty) {
                    if (widget.friendList[index].username!
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase())) {
                      return friendListTile(
                          index,
                          widget.friendList[index].profilePicture ?? "",
                          widget.friendList[index].username ?? "");
                    } else {
                      return const SizedBox();
                    }
                  } else {
                    return friendListTile(
                        index,
                        widget.friendList[index].profilePicture ?? "",
                        widget.friendList[index].username ?? "");
                  }
                },
              ),
            ),
          ],
        ));
  }

  ListTile friendListTile(int index, String profilePic, String username) {
    return ListTile(
      onTap: () {},
      trailing: Container(
        height: 30,
        width: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[300],
        ),
        child: TextButton(
          child: const Text(
            "Unfriend",
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
            ),
          ),
          onPressed: () {},
        ),
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: CachedNetworkImage(
            imageUrl: profilePic, height: 45, width: 45, fit: BoxFit.cover),
      ),
      title: Text(username),
    );
  }
}
