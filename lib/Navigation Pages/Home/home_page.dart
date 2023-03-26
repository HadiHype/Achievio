import 'dart:math';

import 'package:achievio/User%20Interface/app_colors.dart';
import 'package:flutter/material.dart';
import 'Widgets/card_groups.dart';
import '../../User Interface/variables.dart';

import 'Widgets/custom_text_button.dart';
import 'Widgets/custom_text_field.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FocusNode focusNode = FocusNode();
  TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        // No appbar provided to the Scaffold, only a body with a
        // CustomScrollView.
        backgroundColor: kBackgroundColor,
        body: SafeArea(
          child: CustomScrollView(
            // remove splash color
            physics: const ScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            slivers: [
              // Add the app bar to the CustomScrollView.
              SliverAppBar(
                flexibleSpace: upperSliver(),
                floating: true,
                expandedHeight: 70,
                toolbarHeight: 70,
                // backgroundColor: const Color.fromARGB(255, 233, 241, 250),
                backgroundColor: Colors.white70,
                elevation: 0,
              ),

              SliverAppBar(
                flexibleSpace: lowerSliver(),
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

              // Next, create a SliverList
              SliverList(
                // Use a delegate to build items as they're scrolled on screen.
                delegate: SliverChildBuilderDelegate(
                  (context, index) => GroupCard(
                      title: titles[index],
                      isStarred: isStarred[index],
                      subTitle: subTitles[index],
                      numbOfTasksAssigned: Random().nextInt(100)),
                  childCount: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column upperSliver() {
    return Column(
      children: [
        Column(
          children: [
            Row(
              children: const [
                Padding(
                  padding: EdgeInsets.only(left: 20, top: 20, right: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Image(
                      image: AssetImage("assets/images/Profile_Image.jpg"),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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
    );
  }

  Column lowerSliver() {
    return Column(
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
                ),
              ),
            ),
            // filter Icon button
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: IconButton(
                onPressed: () {},
                splashColor: kLightSecondaryColor,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashRadius: 20,
                icon: const Icon(
                  Icons.filter_list_rounded,
                  color: kSecondaryColor,
                  size: 28,
                ),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            CustomTextButton(
              stringText: "Archived Groups",
              onPressed: null,
              padding: EdgeInsets.only(left: 10),
            ),
            CustomTextButton(
              stringText: "Create Group",
              onPressed: null,
              padding: EdgeInsets.only(right: 10),
            ),
          ],
        ),
      ],
    );
  }
}
