import 'package:flutter/material.dart';

class GeneralListSettingsTab extends StatelessWidget {
  final ScrollController scrollController;

  const GeneralListSettingsTab({Key key, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      children: [],
    );
  }
}
