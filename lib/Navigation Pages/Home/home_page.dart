import 'package:achievio/User%20Interface/app_colors.dart';
import 'package:flutter/material.dart';
import 'Widgets/Slivers/list_layout.dart';
import 'Widgets/Slivers/lower_sliver.dart';
import 'Widgets/card_groups.dart';
import '../../User Interface/variables.dart';
import 'Widgets/nav_drawer.dart';
import 'Widgets/Slivers/upper_sliver.dart';

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
            profilePic: 'assets/images/Profile_Pic.jpg',
            isArchived: isArchived[i],
          ),
        );
      }

      defined = true;
    }

    for (int i = 0; i < groupCards.length; i++) {
      if (groupCards[i].isArchived == false) {
        groupCards[i].visible = true;
      }
    }

    groupCardsSorted.addAll(groupCards);

    super.initState();
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
        // hide keyboard when tapped outside of the search bar
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
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Upper sliver app bar that is responsible for the app title, user profile picture, and drawer logic
                UpperSliver(globalKey: _key),

                // Lower sliver that is responsible for the search bar and the logic behind it.
                // Also, it is responsible for the sorting of the group cards
                LowerSliver(
                    focusNode: focusNode,
                    controller: controller,
                    groupCardsSorted: groupCardsSorted),

                // A sliver list layout of cards that changes based on the search, archiving, filtering, and sorting.
                ListLayout(groupCardsSorted: groupCardsSorted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
