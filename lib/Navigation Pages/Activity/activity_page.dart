import 'package:achievio/User%20Interface/app_colors.dart';
import 'package:flutter/material.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Activity',
          style: TextStyle(
            color: kTitleColor,
            fontSize: MediaQuery.of(context).size.width * 0.07,
          ),
        ),

        //transparent appbar
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Activity Page'),
      ),
    );
  }
}
