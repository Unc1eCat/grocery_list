import 'package:flutter/material.dart';
import 'package:grocery_list/widgets/smart_text_field.dart';

class ListItemProperty extends StatelessWidget {
  final String label;
  final double width;
  final TextInputType keyboardType;
  final VoidCallback onEditingComplete;
  final GlobalKey textFieldKey;

  ListItemProperty({
    this.textFieldKey,
    this.width = 110,
    this.label,
    this.keyboardType,
    this.onEditingComplete,
  });

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
              child: SmartTextField(
                key: textFieldKey,
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
