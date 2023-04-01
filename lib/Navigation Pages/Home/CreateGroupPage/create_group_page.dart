import 'package:achievio/User%20Interface/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:achievio/User Interface/variables.dart';

import '../../../Models/user.dart';
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
  List<User> usersOfGroup = <User>[];
  List<bool> isCheckedList = List<bool>.filled(10, false);
  bool _isSelected = false;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

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
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
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
    ModalRoute.of(context)
        ?.addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isSelected
          ? FloatingActionButton.extended(
              onPressed: () {
                // create group
                // navigate to group page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DescribeGroup(),
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
        leading: _isSearching ? const BackButton() : null,
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
      // from list of users, select users to add to group
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          // return list tile for each user according to search query

          if (searchQuery.isEmpty) {
            return ListTile(
              title: Text(
                users[index].name,
                style: const TextStyle(fontSize: 16),
              ),
              leading: const CircleAvatar(
                backgroundImage: AssetImage("assets/images/Profile_Image.jpg"),
              ),
              trailing: Checkbox(
                value: isCheckedList[index],
                fillColor: MaterialStateProperty.all(kTertiaryColor),
                onChanged: (value) {
                  // add user to group
                  // if user is already in group, remove user from group
                  // change value of checkbox
                  setState(
                    () {
                      if (isCheckedList[index] == false) {
                        usersOfGroup.add(users[index]);
                        isCheckedList[index] = true;
                      } else {
                        usersOfGroup.remove(users[index]);
                        isCheckedList[index] = false;
                      }

                      if (isCheckedList.contains(true)) {
                        _isSelected = true;
                      } else {
                        _isSelected = false;
                      }
                    },
                  );
                },
              ),
            );
          } else {
            if (users[index].name.toLowerCase().contains(searchQuery)) {
              return ListTile(
                title: Text(users[index].name),
                leading: const CircleAvatar(
                  backgroundImage:
                      AssetImage("assets/images/Profile_Image.jpg"),
                ),
                trailing: Checkbox(
                  value: isCheckedList[index],
                  fillColor: MaterialStateProperty.all(kTertiaryColor),
                  onChanged: (value) {
                    setState(
                      () {
                        if (isCheckedList[index] == false) {
                          usersOfGroup.add(users[index]);
                          isCheckedList[index] = true;
                        } else {
                          usersOfGroup.remove(users[index]);
                          isCheckedList[index] = false;
                        }
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
        itemCount: users.length,
      ),
    );
  }
}
