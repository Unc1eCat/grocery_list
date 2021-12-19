import 'package:flutter/material.dart';

import 'grocery_item.dart';
import 'item_tag.dart';

class GroceryList {
  final String id;
  final List<GroceryItem> items;
  final List<ItemTag> tags;
  final String title;
  final String defaultCurrency;
  final Set<GroceryItem> purchasedItems;
  final bool usePrice;

  GroceryList({
    this.usePrice = true,
    Set<GroceryItem> removedItems,
    String id,
    List<GroceryItem> items,
    List<ItemTag> tags,
    this.title,
    this.defaultCurrency,
  })  : this.id = id ?? DateTime.now().toString(),
        purchasedItems = removedItems ?? {},
        items = items ?? [],
        tags = tags ?? [];

  GroceryList copyWith({
    bool usePrice,
    Set<GroceryItem> purchasedItems,
    String id,
    List<GroceryItem> items,
    List<ItemTag> tags,
    String title,
    String defaultCurrency,
  }) =>
      GroceryList(
          id: id ?? this.id,
          title: title ?? this.title,
          defaultCurrency: defaultCurrency ?? this.defaultCurrency,
          items: items ?? this.items,
          removedItems: purchasedItems ?? this.purchasedItems,
          usePrice: usePrice ?? this.usePrice);
}
