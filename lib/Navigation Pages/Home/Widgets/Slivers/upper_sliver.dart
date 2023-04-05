import 'package:flutter/material.dart';

import '../../../../User Interface/app_colors.dart';

class UpperSliver extends StatelessWidget {
  const UpperSliver({
    super.key,
    required GlobalKey<ScaffoldState> globalKey,
  }) : _key = globalKey;

  final GlobalKey<ScaffoldState> _key;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: Container(),
      flexibleSpace: Column(
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
