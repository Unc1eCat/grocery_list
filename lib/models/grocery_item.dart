import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grocery_list/models/item_tag.dart';

@immutable
class GroceryItem {
  final String title;
  final bool checked;
  final List<ItemTag> tags;
  final String unit;
  final double quantization;
  final bool integerQuantization;
  final String currency;
  final double price;
  final double amount;

  const GroceryItem({
    this.unit = "",
    this.quantization = 1.0,
    this.integerQuantization = true,
    this.currency = "\$",
    this.price = 0.0,
    this.amount = 1.0,
    this.title = "Test item",
    this.checked = false,
    this.tags = const [
      ItemTag(color: Colors.red, title: "Test red tag"),
      ItemTag(color: Colors.blue, title: "Test blue tag"),
      ItemTag(color: Colors.green, title: "Test green tag"),
    ],
  });

  GroceryItem copyWith({
    String title,
    bool checked,
    List<ItemTag> tags,
    String unit,
    double quantization,
    bool integerQuantization,
    String currency,
    double price,
    double amount,
  }) {
    return GroceryItem(
      amount: amount ?? this.amount,
      checked: checked ?? this.checked,
      currency: currency ?? this.currency,
      integerQuantization: integerQuantization ?? this.integerQuantization,
      price: price ?? this.price,
      quantization: quantization ?? this.quantization,
      tags: tags ?? this.tags,
      title: title ?? this.title,
      unit: unit ?? this.unit,
    );
  }
}
