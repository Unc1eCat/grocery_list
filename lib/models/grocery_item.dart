import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grocery_list/models/grocery_prototype.dart';
import 'package:grocery_list/models/item_tag.dart';

abstract class GroceryItem {
  String get id;
  String get title;
  bool get checked;
  List<ItemTag> get tags;
  String get unit;
  double get quantization;
  int get quantizationDecimalNumbersAmount;
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

  factory GroceryItem.fromJson(Map<String, Object> from)
  {
    // TODO: Implement
  }

  Map<String, Object> toJson();
}

@immutable
class ProductlessGroceryItem implements GroceryItem {
  final String id;
  final String title;
  final bool checked;
  final List<ItemTag> tags;
  final String unit;
  final double quantization;
  final int quantizationDecimalNumbersAmount;
  final String currency;
  final double price;
  final double amount;
  final GroceryPrototype boundPrototype;

  ProductlessGroceryItem({
    String id,
    this.unit = "it.",
    this.quantization = 1.0,
    this.quantizationDecimalNumbersAmount = 0,
    this.currency = "₽",
    this.price = 0.0,
    this.amount = 0.0,
    this.title = "New item",
    this.checked = false,
    this.boundPrototype,
    this.tags = const [
      // ItemTag(color: Colors.red, title: "Test red tag"),
      // ItemTag(color: Colors.blue, title: "Test blue tag"),
      // ItemTag(color: Colors.green, title: "Test green tag"),
    ],
  }) : id = id ?? DateTime.now().toString();

  // Map<String, Object> toJson() {
  //   return boundPrototypeId == null
  //       ? {
  //           "id": id,
  //           "title": title,
  //           "checked": checked,
  //           "tags": "", // TODO: TAGS
  //           "unit": unit,
  //           "quantization": quantization,
  //           "currency": currency,
  //           "price": price,
  //           "amount": amount,
  //           "fractionDigits": quantizationDecimalNumbersAmount,
  //         }
  //       : {
  //           "id": id,
  //           "checked": checked,
  //           "amount": amount,
  //           "boundPrototypeId": boundPrototype.id,
  //         };
  // }

  // static GroceryItem fromJson(Map<String, dynamic> json) {
  //   if (json.containsKey("boundPrototypeId")) {
  //     return GroceryItem(
  //       id: json["id"],
  //       amount: json["amount"],
  //       checked: json["checked"],
  //       boundPrototype: json["boundPrototypeId"],
  //     );
  //   } else {
  //     return GroceryItem(
  //       id: json["id"],
  //       amount: json["amount"],
  //       checked: json["checked"],
  //       currency: json["currency"],
  //       price: json["price"],
  //       quantization: json["quantization"],
  //       quantizationDecimalNumbersAmount: json["fractionDigits"],
  //       tags: <ItemTag>[], // TODO: TAGS
  //       title: json["title"],
  //       unit: json["unit"],
  //     );
  //   }
  // }

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
            quantizationDecimalNumbersAmount: quantizationDecimalNumbersAmount ?? this.quantizationDecimalNumbersAmount,
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
            id: id ?? this.id,
            boundPrototype: boundPrototype,
          );
  }

  GroceryPrototype createPrototype({String id}) {
    return GroceryPrototype(
      id: id,
      currency: currency,
      price: price,
      quantization: quantization,
      quantizationDecimalNumbersAmount: quantizationDecimalNumbersAmount,
      tags: tags,
      title: title,
      unit: unit,
    );
  }

  @override
  Map<String, Object> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class ProductfulGroceryItem implements GroceryItem {
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
  int get quantizationDecimalNumbersAmount => boundPrototype.quantizationDecimalNumbersAmount;

  @override
  List<ItemTag> get tags => throw UnimplementedError();

  @override
  String get title => boundPrototype.title;

  @override
  String get unit => boundPrototype.unit;

  ProductfulGroceryItem({
    this.amount = 0.0,
    this.boundPrototype,
    this.checked = false,
    this.id,
  });

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
            quantizationDecimalNumbersAmount: quantizationDecimalNumbersAmount ?? this.quantizationDecimalNumbersAmount,
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
            id: id ?? this.id,
            boundPrototype: boundPrototype,
          );
  }

  @override
  Map<String, Object> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
