import 'package:flutter/foundation.dart';
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
  final String price;
  final String amount;

  GroceryItem({
    this.unit,
    this.quantization,
    this.integerQuantization,
    this.currency,
    this.price,
    this.amount,
    this.title,
    this.checked,
    this.tags,
  });
}
