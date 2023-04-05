import 'package:flutter/material.dart';

class StackedAvatars extends StatelessWidget {
  const StackedAvatars({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        avatars("assets/images/Profile_Image.jpg", 7.5),
        avatars("assets/images/Profile_Image.jpg", 19.5),
        avatars("assets/images/Profile_Image.jpg", 31.5),
      ],
    );
  }

  Padding avatars(String image, double leftPadding) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: CircleAvatar(
        radius: 10,
        backgroundImage: AssetImage(image),
      ),
    );
  }
}
