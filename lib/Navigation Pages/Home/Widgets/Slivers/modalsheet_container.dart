import 'package:flutter/material.dart';

import '../../../../User Interface/app_colors.dart';
import '../../../../User Interface/variables.dart';

class ModelSheetContainer extends StatelessWidget {
  const ModelSheetContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              "Filter",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kTitleColor,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            color: kBlueGreyColor,
            thickness: 1,
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Text(
                "Sort by",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kTitleColor,
                ),
              ),
              Text(
                "Filter by",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kTitleColor,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StatefulBuilder(
                builder: (context, setState) => DropdownButton<String>(
                  value: dropDownValue,
                  items: <String>[
                    'default',
                    'Alphabetically',
                    'Tasks',
                    'Starred',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      dropDownValue = val!;
                    });
                  },
                ),
              ),
              StatefulBuilder(
                builder: (context, setState) => DropdownButton<String>(
                  value: dropDownValue2,
                  items: <String>[
                    'All',
                    'Starred',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      dropDownValue2 = val!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
