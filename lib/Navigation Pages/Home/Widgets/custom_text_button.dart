import 'package:achievio/User%20Interface/app_colors.dart';
import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    super.key,
    required this.stringText,
    required this.onPressed,
    required this.padding,
  });

  final String stringText;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          stringText,
          style: const TextStyle(
            color: kBlueGreyColor,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
