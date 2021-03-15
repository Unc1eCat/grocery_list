import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:grocery_list/models/item_tag.dart';
import 'dart:convert' as conv;
import 'dart:io';

import '../main.dart';

// TODO: Make separate update state for every property of the grocery item
class GroceryListBloc extends Cubit<GroceryListState> {
  Map<String, GroceryItem> _items = <String, GroceryItem>{};
  Map<String, GroceryItem> get items => Map<String, GroceryItem>.unmodifiable(_items);

  GroceryItem getItemOfId(String id) => _items[id];

  GroceryListBloc(this._items) : super(GroceryListState());
  GroceryListBloc.initFromFiles() : super(GroceryListState()) {
    fetchItems();
  }

  Map<String, Object> toJsonItems() {
    var ret = <Map<String, Object>>[];

    for (var i in _items.values) {
      ret.add(i.toJson());
    }

    return {"grocery_item": ret};
  }

  void initItemsFromJson(Map<String, dynamic> json) {
    for (Map<String, dynamic> i in json["grocery_items"]) {
      GroceryItem item = GroceryItem.fromJson(i);
      _items.putIfAbsent(item.id, () => item);
    }
  }

  void saveItems() {
    TheApp.groceryItemsFile.writeAsStringSync(conv.jsonEncode(toJsonItems()));
  }

  void fetchItems() {
    try {
      initItemsFromJson(conv.jsonDecode(TheApp.groceryItemsFile.readAsStringSync()));
    } catch (exc) {
      print("Failed to fetch files from the file or the file is not initialized. Returning empty list");
      print(exc);

      _items = <String, GroceryItem>{};
    }

    emit(ItemsFetchedState(items));
  }

  void createItem(String id, GroceryItem newItem) {
    _items.putIfAbsent(id, () => newItem);

    emit(ItemCreatedState(id, items));

    saveItems();
  }

  void deleteItem(String id) {
    _items.remove(id);

    emit(ItemDeletedState(id));

    saveItems();
  }

  void updateItem(String id, GroceryItem newItem) {
    var updatedChecked = newItem.checked != _items[id].checked;

    _items.update(id, (value) => newItem);

    emit(ItemChangedState(items, id));
    if (updatedChecked) {
      emit(CheckedChangedState(id, newItem.checked));
    }

    saveItems();
  }
}

// STATEs

class GroceryListState extends Equatable {
  @override
  List<Object> get props => [];
}

// class InitialState extends GroceryListState {}

class ItemChangedState extends GroceryListState {
  final Map<String, GroceryItem> items;
  final String id;

  ItemChangedState(this.items, this.id);

  @override
  List<Object> get props => super.props..add(items)..add(id);
}

class CheckedChangedState extends GroceryListState {
  final bool checked;
  final String id;

  CheckedChangedState(this.id, this.checked);

  @override
  List<Object> get props => super.props..add(checked)..add(id);
}

class ItemDeletedState extends GroceryListState {
  final String id;

  ItemDeletedState(this.id);

  @override
  List<Object> get props => super.props..add(id);
}

class ItemCreatedState extends GroceryListState {
  final String id;
  final Map<String, GroceryItem> items;

  ItemCreatedState(this.id, this.items);

  @override
  List<Object> get props => super.props..add(id)..add(items);
}

class ItemsFetchedState extends GroceryListState {
  final Map<String, GroceryItem> items;

  ItemsFetchedState(this.items);

  @override
  List<Object> get props => super.props..add(items);
}
