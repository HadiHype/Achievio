import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupDetailsPage extends StatefulWidget {
  final String groupId;
  final String groupTitle;
  final String groupPicture;
  final String groupDescription;

  const GroupDetailsPage(
      {Key? key,
      required this.groupId,
      required this.groupTitle,
      required this.groupPicture,
      required this.groupDescription})
      : super(key: key);

  @override
  _GroupDetailsPageState createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  Future<List<DocumentSnapshot>> getMembers() async {
    final membersQuery = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('users')
        .orderBy('points', descending: true)
        .get();

    return membersQuery.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Group Details'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: getMembers(),
        builder: (BuildContext context,
            AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('An error occurred'));
          }

          if (snapshot.hasData) {
            return Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(widget.groupPicture),
                    radius: 30,
                  ),
                  title: Text(widget.groupTitle,
                      style: const TextStyle(fontSize: 20)),
                  subtitle: Text(widget
                      .groupDescription), // Replace with your group description
                ),
                const Divider(height: 10, thickness: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map<String, dynamic> memberData =
                          snapshot.data![index].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(memberData['profilePicture']),
                        ),
                        title: Text(memberData['username']),
                        subtitle: Text('Points: ${memberData['points']}'),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('No members found'));
        },
      ),
    );
  }
}
