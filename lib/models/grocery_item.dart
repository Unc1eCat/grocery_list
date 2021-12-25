import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grocery_list/models/grocery_prototype.dart';
import 'package:grocery_list/models/item_tag.dart';
import 'package:grocery_list/utils/serealization_utils.dart';

abstract class GroceryItem implements ToJson {
  String get id;
  String get title;
  bool get checked;
  List<ItemTag> get tags;
  String get unit;
  double get quantization;
  int get quantizationFractionDigits;
  String get currency;
  double get price;
  double get amount;
  GroceryPrototype get boundPrototype;

  GroceryItem copyWith({
    String id,
    String title,
    bool checked,
    List<ItemTag> tags,
    String unit,
    double quantization,
    int quantizationDecimalNumbersAmount,
    String currency,
    double price,
    double amount,
    GroceryPrototype boundPrototype,
    bool updatePrototype = false,
  });

  GroceryItem();

  factory GroceryItem.fromJson(Map<String, Object> from) {
    // TODO: Implement
  }

  GroceryPrototype createPrototype();

  GroceryItem copyWithAmountSnappedToQuantization() {
    var newAmount = (this.amount / this.quantization).round() * this.quantization;

    if (newAmount == 0.0) {
      newAmount = this.quantization;
    }

    return this.copyWith(amount: newAmount);
  }
}

@immutable
class ProductlessGroceryItem extends GroceryItem {
  final String id;
  final String title;
  final bool checked;
  final List<ItemTag> tags;
  final String unit;
  final double quantization;
  final int quantizationFractionDigits;
  final String currency;
  final double price;
  final double amount;
  final GroceryPrototype boundPrototype;

  ProductlessGroceryItem({
    String id,
    this.unit = "it.",
    this.quantization = 1.0,
    this.quantizationFractionDigits = 0,
    this.currency = "₽",
    this.price = 0.0,
    this.amount = 0.0,
    this.title = "New item",
    this.checked = false,
    this.boundPrototype,
    this.tags = const [],
  }) : id = id ?? DateTime.now().toString();

  @override
  GroceryItem copyWith({
    String id,
    String title,
    bool checked,
    List<ItemTag> tags,
    String unit,
    double quantization,
    int quantizationDecimalNumbersAmount,
    String currency,
    double price,
    double amount,
    GroceryPrototype boundPrototype,
    bool updatePrototype = false,
  }) {
    bool wontHavePrototype = updatePrototype ? boundPrototype == null : this.boundPrototype == null;
    return wontHavePrototype
        ? ProductlessGroceryItem(
            id: id ?? this.id,
            amount: amount ?? this.amount,
            checked: checked ?? this.checked,
            currency: currency ?? this.currency,
            quantizationFractionDigits: quantizationDecimalNumbersAmount ?? this.quantizationFractionDigits,
            price: price ?? this.price,
            quantization: quantization ?? this.quantization,
            tags: tags ?? this.tags,
            title: title ?? this.title,
            unit: unit ?? this.unit,
            boundPrototype: updatePrototype ? boundPrototype : this.boundPrototype,
          )
        : ProductfulGroceryItem(
            amount: amount ?? this.amount,
            checked: checked ?? this.checked,
            tags: tags ?? this.tags,
            id: id ?? this.id,
            boundPrototype: updatePrototype ? boundPrototype : this.boundPrototype,
          );
  }

  @override
  GroceryPrototype createPrototype() {
    return GroceryPrototype(
      id: DateTime.now().toString(),
      currency: currency,
      price: price,
      quantization: quantization,
      quantizationFractionDigits: quantizationFractionDigits,
      title: title,
      unit: unit,
    );
  }

  @override
  Map<String, Object> toJson() => {
        "id": id,
        "currency": currency,
        "price": price,
        "quantization": quantization,
        "quantizationFractionDigits": quantizationFractionDigits,
        "tags": tags.map((e) => e.id),
        "amount": amount,
        "checked": checked,
      };
}

class ProductfulGroceryItem extends GroceryItem {
  @override
  final double amount;

  @override
  final GroceryPrototype boundPrototype;

  @override
  final bool checked;

  @override
  String get currency => boundPrototype.currency;

  @override
  final String id;

  @override
  double get price => boundPrototype.price;

  @override
  double get quantization => boundPrototype.quantization;

  @override
  int get quantizationFractionDigits => boundPrototype.quantizationFractionDigits;

  @override
  final List<ItemTag> tags;

  @override
  String get title => boundPrototype.title;

  @override
  String get unit => boundPrototype.unit;

  ProductfulGroceryItem({
    this.tags,
    this.amount = 0.0,
    this.boundPrototype,
    this.checked = false,
    String id,
  }) : this.id = id ?? DateTime.now().toString();

  @override
  GroceryItem copyWith(
      {String id,
      String title,
      bool checked,
      List<ItemTag> tags,
      String unit,
      double quantization,
      int quantizationDecimalNumbersAmount,
      String currency,
      double price,
      double amount,
      GroceryPrototype boundPrototype,
      bool updatePrototype = false}) {
    bool wontHavePrototype = updatePrototype ? boundPrototype == null : this.boundPrototype == null;
    return wontHavePrototype
        ? ProductlessGroceryItem(
            id: id ?? this.id,
            amount: amount ?? this.amount,
            checked: checked ?? this.checked,
            currency: currency ?? this.currency,
            quantizationFractionDigits: quantizationDecimalNumbersAmount ?? this.quantizationFractionDigits,
            price: price ?? this.price,
            quantization: quantization ?? this.quantization,
            tags: tags ?? this.tags,
            title: title ?? this.title,
            unit: unit ?? this.unit,
            boundPrototype: updatePrototype ? boundPrototype : this.boundPrototype,
          )
        : ProductfulGroceryItem(
            amount: amount ?? this.amount,
            checked: checked ?? this.checked,
            tags: tags ?? this.tags,
            id: id ?? this.id,
            boundPrototype: updatePrototype ? boundPrototype : this.boundPrototype,
          );
  }

  @override
  GroceryPrototype createPrototype() {
    return boundPrototype;
  }

  @override
  Map<String, Object> toJson() => {
        "id": id,
        "boundPrototype": boundPrototype.id,
        "tags": tags.map((e) => e.id),
        "amount": amount,
        "checked": checked,
      };
}
