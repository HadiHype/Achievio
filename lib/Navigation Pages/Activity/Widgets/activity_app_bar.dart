import 'package:flutter/material.dart';

import '../../../User Interface/app_colors.dart';

class ActivityAppBar extends StatelessWidget {
  const ActivityAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SliverAppBar(
      centerTitle: true,
      title: Text(
        "Activity",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: kTitleColor,
        ),
      ),
      pinned: true,
      expandedHeight: 55,
      toolbarHeight: 55,
      backgroundColor: Colors.white70,
      elevation: 0,
    );
  }
}
