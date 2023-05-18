import 'package:achievio/User%20Interface/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../Models/userinfo.dart';
import 'describe_group.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "";
  List<UserData> usersOfGroup = <UserData>[];
  List<bool> isCheckedList = List<bool>.filled(10, false);
  bool isSelected = false;

  final authUser = FirebaseAuth.instance;

  // Logged in user
  User? user = FirebaseAuth.instance.currentUser;

  // Logged in user data
  UserData currUser = UserData();

  // List of all the users friends
  List<UserData> friends = <UserData>[];

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: "Search for friends...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    // if searching, show clear button
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

  void _startSearch() {
    // add local history entry to route
    ModalRoute.of(context)
        ?.addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    // update search query
    setState(() {
      searchQuery = newQuery;
    });
  }

  void _stopSearching() {
    // clear search query
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    // clear search query
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }

  @override
  void initState() {
    super.initState();
    // get friends list from database
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((value) {
      currUser = UserData.fromMap(value.data()!);

      for (int i = 0; i < currUser.friends.length; i++) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(currUser.friends[i])
            .get()
            .then((value) {
          UserData tempUser = UserData.fromMap(value.data()!);
          setState(() {
            friends.add(tempUser);
          });
        });
      }

      for (int i = 0; i < currUser.friendRequestSent.length; i++) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(currUser.friendRequestSent[i])
            .get()
            .then((value) {
          UserData tempUser = UserData.fromMap(value.data()!);
          setState(() {
            friends.add(tempUser);
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isSelected
          ? FloatingActionButton.extended(
              onPressed: () {
                // navigate to group page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DescribeGroup(usersOfGroup),
                  ),
                );
              },
              label: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              backgroundColor: kTertiaryColor,
              elevation: 2,
            )
          : null,
      appBar: AppBar(
        // if searching, show back button else show search icon
        leading: _isSearching ? const BackButton() : null,
        // if searching, show search field else show title
        title: _isSearching
            ? _buildSearchField()
            : const Text(
                'Create a Group',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
        actions: _buildActions(),
        elevation: 1,
        backgroundColor: kTertiaryColor,
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          // return list tile for each user according to search query
          if (searchQuery.isEmpty) {
            // if search query is empty, return list tile for all users
            return ListTile(
              title: Text(friends[index].username ?? ""),
              leading: CircleAvatar(
                backgroundImage:
                    NetworkImage(friends[index].profilePicture ?? ""),
              ),
              trailing: Checkbox(
                value: isCheckedList[index],
                fillColor: MaterialStateProperty.all(kTertiaryColor),
                onChanged: (value) {
                  setState(
                    () {
                      addUserToGroup(index);
                    },
                  );
                },
              ),
            );
          } else {
            // if search query is not empty, return list tile only if user name contains search query
            if (friends[index].username!.toLowerCase().contains(searchQuery)) {
              return ListTile(
                title: Text(friends[index].username ?? ""),
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(friends[index].profilePicture ?? ""),
                ),
                trailing: Checkbox(
                  value: isCheckedList[index],
                  fillColor: MaterialStateProperty.all(kTertiaryColor),
                  onChanged: (value) {
                    setState(
                      () {
                        addUserToGroup(index);
                      },
                    );
                  },
                ),
              );
            } else {
              return const SizedBox();
            }
          }
        },
        itemCount: friends.length,
      ),
    );
  }

  void addUserToGroup(int index) {
    if (isCheckedList[index] == false) {
      // add user to group
      usersOfGroup.add(friends[index]);
      isCheckedList[index] = true;
    } else {
      // remove user from group
      usersOfGroup.remove(friends[index]);
      isCheckedList[index] = false;
    }

    if (isCheckedList.contains(true)) {
      // if at least one user is selected, show floating action button
      isSelected = true;
    } else {
      // if no user is selected, hide floating action button
      isSelected = false;
    }
  }
}
