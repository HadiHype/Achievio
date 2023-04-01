import 'package:flutter/material.dart';

import '../../../User Interface/app_colors.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.only(left: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            const CircleAvatar(
              radius: 32,
              backgroundImage: AssetImage("assets/images/Profile_Image.jpg"),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Youssef Mneimneh",
              style: TextStyle(
                color: kTitleColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 2.5,
            ),
            GestureDetector(
              child: const Padding(
                padding: EdgeInsets.only(left: 2.5),
                child: Text(
                  "view profile",
                  style: TextStyle(
                    color: kSubtitleColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 2.5),
              child: Divider(
                height: 5,
                endIndent: 30,
              ),
            ),
            const SizedBox(
              height: 7.5,
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 30,
              ),
              child: TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.only(left: 3.5),
                  ),
                  overlayColor: MaterialStateProperty.all(
                    kGreyColor.withOpacity(0.1),
                  ),
                ),
                onPressed: () {},
                child: Padding(
                  padding: const EdgeInsets.only(left: 3.5),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.settings,
                        size: 21,
                        color: kBlueGreyColor,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: kBlueGreyColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 30),
              child: TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.only(left: 3.5),
                  ),
                  overlayColor: MaterialStateProperty.all(
                    kGreyColor.withOpacity(0.1),
                  ),
                ),
                onPressed: () {},
                child: Padding(
                  padding: const EdgeInsets.only(left: 3.5),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.local_post_office_sharp,
                        size: 21,
                        color: kBlueGreyColor,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "Send Feedback",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: kBlueGreyColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 30),
              child: TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.only(left: 3.5),
                  ),
                  overlayColor: MaterialStateProperty.all(
                    kGreyColor.withOpacity(0.1),
                  ),
                ),
                onPressed: () {},
                child: Padding(
                  padding: const EdgeInsets.only(left: 3.5),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.people_rounded,
                        size: 21,
                        color: kBlueGreyColor,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "Friends",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: kBlueGreyColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}