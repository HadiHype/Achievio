import 'package:flutter/material.dart';

import '../../../User Interface/app_colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.focusNode,
    required this.controller,
  });

  final FocusNode focusNode;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      decoration: const InputDecoration(
        border: InputBorder.none,
        prefixIcon: Icon(
          Icons.search,
          size: 16,
          color: kGreyColor,
        ),
        hintText: "Search",
        hintStyle: TextStyle(
          fontSize: 15.5,
          color: kGreyColor,
        ),
      ),
    );
  }
}
