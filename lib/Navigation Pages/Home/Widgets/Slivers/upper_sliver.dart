import 'package:flutter/material.dart';

import '../../../../User Interface/app_colors.dart';

class UpperSliver extends StatefulWidget {
  const UpperSliver({
    super.key,
    required GlobalKey<ScaffoldState> globalKey,
  });

  @override
  State<UpperSliver> createState() => _UpperSliverState();
}

class _UpperSliverState extends State<UpperSliver> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: Container(),
      flexibleSpace: Column(
        children: [
          Column(
            children: [
              Row(
                children: const [
                  // GestureDetector(
                  //   onTap: () {
                  //     widget._key.currentState!.openDrawer();
                  //     FocusScope.of(context).unfocus();
                  //   },
                  //   child: Padding(
                  //     padding:
                  //         const EdgeInsets.only(left: 20, top: 20, right: 20),
                  //     child: ClipRRect(
                  //       borderRadius:
                  //           const BorderRadius.all(Radius.circular(10)),
                  //       child: Image.network(
                  //         url,
                  //         width: 40,
                  //         height: 40,
                  //         fit: BoxFit.cover,
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  // get the user's profile picture from firebase storage and display it using streambuilder
                  // StreamBuilder(
                  //     stream: FirebaseFirestore.instance
                  //         .collection("users")
                  //         .snapshots(),
                  //     builder: (context, snapshot) {
                  //       if (snapshot.hasError) {
                  //         return Text("Something went wrong");
                  //       }

                  //       if (snapshot.connectionState ==
                  //           ConnectionState.waiting) {
                  //         print("in waiting");
                  //         return const CircularProgressIndicator();
                  //       }

                  //       if (snapshot.connectionState == ConnectionState.none) {
                  //         print("in none");
                  //         return const CircularProgressIndicator();
                  //       }

                  //       return GestureDetector(
                  //         onTap: () {
                  //           widget._key.currentState!.openDrawer();
                  //           FocusScope.of(context).unfocus();
                  //         },
                  //         child: Padding(
                  //           padding: const EdgeInsets.only(
                  //               left: 20, top: 20, right: 20),
                  //           child: ClipRRect(
                  //             borderRadius:
                  //                 const BorderRadius.all(Radius.circular(10)),
                  //             child: FadeInImage(
                  //               placeholder: const AssetImage(
                  //                   "assets/images/Profile_Image.jpg"),
                  //               image: NetworkImage(
                  //                 snapshot.data!.docs[0]['profilePicture'],
                  //               ),
                  //               width: 40,
                  //               height: 40,
                  //               fit: BoxFit.cover,
                  //             ),
                  //           ),
                  //         ),
                  //       );
                  //     }),

                  Padding(
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
      ),
      floating: true,
      expandedHeight: 70,
      toolbarHeight: 70,
      // backgroundColor: const Color.fromARGB(255, 233, 241, 250),
      backgroundColor: Colors.white70,
      elevation: 0,
    );
  }
}
