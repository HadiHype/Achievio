import 'package:flutter/material.dart';

import '../../../User Interface/app_colors.dart';
import 'card_groups.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.focusNode,
    required this.controller,
    required this.groupCards,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final List<GroupCard> groupCards;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      controller: widget.controller,
      onChanged: (value) {
        setState(
          () {
            if (value.isEmpty) {
              for (var card in widget.groupCards) {
                card.visible = true;
              }
            } else {
              for (var card in widget.groupCards) {
                if (card.title.toLowerCase().contains(value.toLowerCase())) {
                  card.visible = true;
                } else {
                  card.visible = false;
                }
              }
            }
          },
        );
      },
      decoration: const InputDecoration(
        border: InputBorder.none,
        prefixIcon: Icon(
          Icons.search,
          size: 16,
          color: kBlueGreyColor,
        ),
        hintText: "Search",
        hintStyle: TextStyle(
          fontSize: 15.5,
          color: kBlueGreyColor,
        ),
      ),
    );
  }
}
