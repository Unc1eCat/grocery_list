import 'package:flutter/material.dart';
import 'package:grocery_list/widgets/smart_text_field.dart';

class BeautifulTextField extends StatelessWidget {
  final String label;
  final double width;
  final TextInputType keyboardType;
  final OnEditingCompleteCallback onEditingComplete;
  final TextEditingController controller;
  final FocusNode focusNode;
  final GlobalKey textFieldKey;

  BeautifulTextField({
    this.textFieldKey,
    this.width = double.infinity,
    this.label,
    this.keyboardType,
    this.onEditingComplete,
    this.controller,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      width: width,
      child: Stack(
        children: [
          Positioned(
            top: 6,
            left: 0,
            bottom: 0,
            right: 0,
            child: Material(
              borderRadius: BorderRadius.circular(8),
              color: Color.fromRGBO(30, 30, 30, 0.6),
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            top: 0,
            child: Align(
              alignment: Alignment.center,
              child: SmartTextField(
                key: textFieldKey,
                scrollPadding: EdgeInsets.all(0),
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
                controller: controller,
                focusNode: focusNode,
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
