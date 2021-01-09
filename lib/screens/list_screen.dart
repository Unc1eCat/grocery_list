import 'package:flutter/material.dart';
import 'package:grocery_list/widgets/corner_drawer.dart';

class ListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          Container(
            height: 100,
            // width: 100,
            margin: const EdgeInsets.all(20),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
