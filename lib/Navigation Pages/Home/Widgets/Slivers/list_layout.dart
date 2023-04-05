import 'package:flutter/material.dart';
import '../../../../User Interface/variables.dart';
import '../card_groups.dart';

class ListLayout extends StatefulWidget {
  const ListLayout({
    super.key,
    required this.groupCardsSorted,
  });

  final List<GroupCard> groupCardsSorted;

  @override
  State<ListLayout> createState() => _ListLayoutState();
}

class _ListLayoutState extends State<ListLayout> {
  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraint) => SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            if (index >= groupCards.length) {
              return const Offstage();
            }
            if (groupCards[index].visible &&
                !groupCards[index].isArchived &&
                dropDownValue == 'default') {
              return groupCards[index];
            } else if (groupCards[index].visible &&
                !groupCards[index].isArchived &&
                dropDownValue != 'default') {
              return widget.groupCardsSorted[index];
            } else {
              return const Offstage();
            }
          },
          childCount: groupCards.length,
        ),
      ),
    );
  }
}
