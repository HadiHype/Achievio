import 'package:flutter/material.dart';

import '../../../User Interface/app_colors.dart';

class ActivityAppBar extends StatelessWidget {
  const ActivityAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      centerTitle: true,
      flexibleSpace: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10, left: 10),
            child: Text(
              "Activity",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kTitleColor,
              ),
            ),
          ),
          // TODO: Make the filter button clickable and show a pop up menu
          IconButton(
            onPressed: () {},
            padding: const EdgeInsets.only(top: 5),
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
        ],
      ),
      pinned: true,
      expandedHeight: 55,
      toolbarHeight: 55,
      backgroundColor: Colors.white70,
      elevation: 0,
    );
  }
}
