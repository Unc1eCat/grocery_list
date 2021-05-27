import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:grocery_list/models/grocery_prototype.dart';
import 'package:grocery_list/models/item_tag.dart';
import 'package:grocery_list/widgets/rounded_rolling_switch.dart';
import 'dart:convert' as conv;
import 'dart:io';

import '../main.dart';

// TODO: Make separate update state for every property of the grocery item
class GroceryListBloc extends Cubit<GroceryListState> {
  List<GroceryItem> _items = <GroceryItem>[];
  List<GroceryPrototype> _prototypes = <GroceryPrototype>[]; // TODO: Make it into a map

  List<GroceryItem> get items => List<GroceryItem>.unmodifiable(_items);
  List<GroceryPrototype> get prototypes => List<GroceryPrototype>.unmodifiable(_prototypes);

  GroceryItem getItemOfId(String id) => _items.firstWhere((e) => e.id == id, orElse: () => null);
  int getIndexOfId(String id) => _items.indexWhere((e) => e.id == id);

  GroceryListBloc(this._items) : super(GroceryListState());
  GroceryListBloc.initFromFiles() : super(GroceryListState()) {
    fetchItems();
  }

  Map<String, Object> toJsonItems() {
    var ret = <Map<String, Object>>[];

    for (var i in _items) {
      ret.add(i.toJson());
    }

    return {"grocery_item": ret};
  }

  @override
  onChange(Change change) {
    print("$this has emitted $change");
    super.onChange(change);
  }

  Map<String, Object> toJsonPrototypes() {
    var ret = <Map<String, Object>>[];

    for (var i in _prototypes) {
      ret.add(i.toJson());
    }

    return {"grocery_prototypes": ret};
  }

  void initItemsFromJson(Map<String, dynamic> json) {
    for (Map<String, dynamic> i in json["grocery_item"]) {
      GroceryItem item = GroceryItem.fromJson(i);
      _items.add(item);
    }
  }

  void initPrototypesFromJson(Map<String, dynamic> json) {
    for (Map<String, dynamic> i in json["grocery_prototypes"]) {
      GroceryPrototype prototype = GroceryPrototype.fromJson(i);

      if (!containsPrototype(prototype)) {
        _prototypes.add(prototype);
      }
    }
  }

  void saveItems() {
    TheApp.groceryItemsFile.writeAsStringSync(conv.jsonEncode(toJsonItems()));
  }

  void savePrototypes() {
    TheApp.groceryPrototypesFile.writeAsStringSync(conv.jsonEncode(toJsonPrototypes()));
  }

  void fetchItems() {
    try {
      initItemsFromJson(conv.jsonDecode(TheApp.groceryItemsFile.readAsStringSync()));
    } catch (exc) {
      print("Failed to fetch items from the file or the file is not initialized. Returning empty list");
      print(exc);

      _items = <GroceryItem>[];
    }

    emit(ItemsFetchedState(items));
  }

  void fetchPrototypes() {
    try {
      initPrototypesFromJson(conv.jsonDecode(TheApp.groceryPrototypesFile.readAsStringSync()));
    } catch (exc) {
      print("Failed to fetch prototypes from the file or the file is not initialized. Returning empty list");
      print(exc);

      _prototypes = <GroceryPrototype>[];
    }

    emit(PrototypesFetchedState(prototypes));
  }

  GroceryPrototype getPrototypeOfId(String id)
  {
    return _prototypes.firstWhere((e) => e.id == id);
  }

  void tryAddPrototype(GroceryPrototype prototype) {
    if (!containsPrototype(prototype)) {
      _prototypes.add(prototype);

      emit(PrototypeAddedState(prototypes, prototype));
    }
  }

  void addPrototype(GroceryPrototype prototype) {
    _prototypes.add(prototype);

    emit(PrototypeAddedState(prototypes, prototype));
  }

  GroceryPrototype getPrototypeOfTitle(String title) {
    return _prototypes.firstWhere((e) => e.title == title);
  }

  void deletePrototype(String id) {
    var index = _prototypes.indexWhere((e) => e.id == id);

    if (index == -1) return;

    emit(PrototypeRemovedState(prototypes, _prototypes.removeAt(index)));

    savePrototypes();
  }

  void updatePrototype(GroceryPrototype newPrototype) {
    var index = _prototypes.indexWhere((e) => e.id == newPrototype.id);

    _prototypes[index] = newPrototype;

    emit(PrototypeChangedState(newPrototype));

    savePrototypes();
  }

  void moveItem(int fromIndex, int toIndex) {
    _items.insert(toIndex, _items.removeAt(fromIndex));

    emit(ItemMovedState(items));

    saveItems();
  }

  List<GroceryPrototype> getRelevantPrototypes(int limit, String enteredTitle) {
    if (_prototypes.length == 0) return <GroceryPrototype>[];

    var ret = _prototypes.sublist(0);

    print(ret);

    ret.removeWhere((e) => !e.title.contains(enteredTitle));
    ret.sort((a, b) => a.title.compareTo(b.title)); // Alphabetic
    ret.sort((a, b) => a.title.indexOf(enteredTitle).compareTo(b.title.indexOf(enteredTitle))); // Relevance

    return ret;

    // while (true)
    // {
    //   for (int i = 0; i < _prototypes.length; i++)
    //   {
    //     var v = _prototypes[i];
    //     var iRel = v.title.indexOf(enteredTitle);

    //     while (iRel > _prototypes[i + 1].title.indexOf(enteredTitle))
    //     {
    //       highestRel = iRel;

    //     }
    //   }
    // }
  }

  bool containsPrototype(GroceryPrototype prototype) {
    return _prototypes.any((e) => e.id == prototype.id);
  }

  void createItem(GroceryItem newItem) {
    _items.add(newItem);

    emit(ItemCreatedState(newItem.id, items));

    saveItems();
  }

  void deleteItem(String id) {
    var index = _items.indexWhere((e) => e.id == id);

    emit(ItemDeletedState(_items.removeAt(index), index));

    saveItems();
  }

  void deleteCheckedItems() {
    _items.removeWhere((e) => e.checked);

    emit(ItemDeletedState(null, -1));

    saveItems();
  }

  void updateItem(String id, GroceryItem newItem) {
    var updatedChecked = newItem.checked != getItemOfId(id).checked;
    var updatedProtBinding = newItem.boundPrototypeId != getItemOfId(id).boundPrototypeId;
    _items[getIndexOfId(id)] = newItem;

    // tryAddPrototype(newItem.createPrototype());

    emit(ItemChangedState(items, id, newItem, updatedProtBinding));
    if (updatedChecked) {
      emit(CheckedChangedState(newItem.checked, newItem));
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
  final List<GroceryItem> items;
  final String id;
  final GroceryItem item;
  final bool reboundPrototype;

  ItemChangedState(this.items, this.id, this.item, this.reboundPrototype);

  @override
  List<Object> get props => super.props..add(items)..add(id)..add(item)..add(reboundPrototype);
}

class CheckedChangedState extends GroceryListState {
  final bool checked;
  final GroceryItem item;

  CheckedChangedState(this.checked, this.item);

  @override
  List<Object> get props => super.props..add(checked)..add(item);
}

class ItemDeletedState extends GroceryListState {
  final GroceryItem removedItem;
  final int index;

  ItemDeletedState(this.removedItem, this.index);

  @override
  List<Object> get props => super.props..add(removedItem);
}

class ItemCreatedState extends GroceryListState {
  final String id;
  final List<GroceryItem> items;

  ItemCreatedState(this.id, this.items);

  @override
  List<Object> get props => super.props..add(id)..add(items);
}

class ItemsFetchedState extends GroceryListState {
  final List<GroceryItem> items;

  ItemsFetchedState(this.items);

  @override
  List<Object> get props => super.props..add(items);
}

class PrototypeAddedState extends GroceryListState {
  final List<GroceryPrototype> prototypes;
  final GroceryPrototype prototype;

  PrototypeAddedState(this.prototypes, this.prototype);

  @override
  List<Object> get props => super.props..add(prototypes)..add(prototype);
}

class PrototypeRemovedState extends GroceryListState {
  final List<GroceryPrototype> prototypes;
  final GroceryPrototype prototype;

  PrototypeRemovedState(this.prototypes, this.prototype);

  @override
  List<Object> get props => super.props..add(prototypes)..add(prototype);
}

class PrototypesFetchedState extends GroceryListState {
  // TODO: Combine prototype added, fetched and removed into a single state. Do the same thing for the grocery items
  final List<GroceryPrototype> prototypes;

  PrototypesFetchedState(this.prototypes);

  @override
  List<Object> get props => super.props..add(prototypes);
}

class PrototypeChangedState extends GroceryListState {
  final GroceryPrototype updatedPrototypes;

  PrototypeChangedState(this.updatedPrototypes);

  @override
  List<Object> get props => super.props..add(updatedPrototypes);
}

class ItemMovedState extends GroceryListState {
  final List<GroceryItem> items;

  ItemMovedState(this.items);

  @override
  List<Object> get props => super.props..add(items);
}
