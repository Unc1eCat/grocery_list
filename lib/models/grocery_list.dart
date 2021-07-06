import 'grocery_item.dart';
import 'item_tag.dart';

class GroceryList {
  final String id;
  final List<GroceryItem> items;
  final List<ItemTag> tags;
  final String title;
  final String defaut_currency;
  final Set<GroceryItem> removedItems;

  GroceryList({
    this.removedItems,
    this.id,
    this.items,
    this.tags,
    this.title,
    this.defaut_currency,
  });
}