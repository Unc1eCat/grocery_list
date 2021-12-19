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

  GroceryList({
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
        removedItems: purchasedItems ?? this.purchasedItems
      );
}
