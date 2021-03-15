import 'package:flutter/material.dart';

class ListItemProperty extends StatelessWidget {
  final String label;
  final TextEditingController textEditingController;
  final double width;
  final TextInputType keyboardType;
  final VoidCallback onEditingComplete;

  ListItemProperty({
    Key key,
    this.width = 110,
    this.label,
    this.textEditingController,
    this.keyboardType,
    this.onEditingComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      width: width,
      child: Stack(
        children: [
          Positioned(
            top: 8,
            bottom: 0,
            left: 0,
            right: 0,
            child: Material(
              borderRadius: BorderRadius.circular(8),
              color: Color.fromRGBO(30, 30, 30, 0.6),
              child: SizedBox.expand(),
            ),
          ),
          Positioned(
            left: 8,
            top: 0,
            right: 8,
            bottom: 8,
            child: Material(
              color: Colors.transparent,
              child: TextField(
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  labelStyle: const TextStyle(
                    color: const Color.fromARGB(255, 205, 205, 205),
                    fontSize: 18,
                  ),
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  alignLabelWithHint: true,
                  labelText: label,
                ),
                controller: textEditingController,
                textAlign: TextAlign.center,
                keyboardType: keyboardType,
                onEditingComplete: onEditingComplete,
                onSubmitted: (value) => FocusScope.of(context).unfocus(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
