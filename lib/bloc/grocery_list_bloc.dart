import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:grocery_list/models/grocery_list.dart';
import 'package:grocery_list/models/grocery_prototype.dart';
import 'package:grocery_list/models/item_tag.dart';
import 'package:grocery_list/widgets/rounded_rolling_switch.dart';
import 'dart:convert' as conv;
import 'dart:io';

import '../main.dart';
import '../models/grocery_prototype.dart';

// TODO: Make separate update state for every property of the grocery item
class GroceryListBloc extends Cubit<GroceryListState> { //
  List<GroceryPrototype> _prototypes = <GroceryPrototype>[];
  List<GroceryList> _lists = <GroceryList>[];

  List<GroceryItem> get lists => List<GroceryItem>.unmodifiable(_lists);
  List<GroceryPrototype> get prototypes => List<GroceryPrototype>.unmodifiable(_prototypes);

  GroceryListBloc() : super(GroceryListState());
  GroceryListBloc.initFromFiles() : super(GroceryListState()) {}

  GroceryList getListOfId(String listId) => _lists.firstWhere((e) => e.id == listId);
  GroceryItem getItemOfId(String id, String listId) => getListOfId(listId).items.firstWhere((e) => e.id == id, orElse: () => null);
  GroceryPrototype getPrototypeOfId(String id) => _prototypes.firstWhere((e) => e.id == id, orElse: () => null);

  @override
  onChange(Change change) {
    print("$this has emitted $change");
    super.onChange(change);
  }

  void saveItems() {}

  void savePrototypes() {}

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
    var changedIds = <String>{};
    
    for (var list in _lists) {
      for (var i = 0; i < list.items.length; i++) {
        if (list.items[i].boundPrototype.id == id) {
          list.items[i] = list.items[i].copyWith(boundPrototype: null, updatePrototype: true);
          changedIds.add(list.items[i].id);
        }
      }
    }

    if (index == -1) return;

    emit(PrototypeRemovedState(prototypes, _prototypes.removeAt(index)));
    emit(ItemsChangedState(changedIds, true));

    savePrototypes();
  }

  void updatePrototype(GroceryPrototype newPrototype) {
    var index = _prototypes.indexWhere((e) => e.id == newPrototype.id);

    _prototypes[index] = newPrototype;

    for (var list in _lists)
    {for (var i = 0; i < list.items.length; i++) {
      if (list.items[i].boundPrototype.id == newPrototype.id) {
        list.items[i] = list.items[i].copyWith(boundPrototype: newPrototype, updatePrototype: true);
      }
    }}

    emit(PrototypeChangedState(newPrototype));

    savePrototypes();
  }

  void moveItem(int fromIndex, int toIndex, String listId) {
    var list = getListOfId(listId);
    list.items.insert(toIndex, list.items.removeAt(fromIndex));

    emit(ItemMovedState(list.items, listId));

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

  void createItem(GroceryItem newItem, String listId) {
    var list = getListOfId(listId);
    list.items.add(newItem);

    emit(ItemCreatedState(newItem.id, list.items, listId));

    saveItems();
  }

  void deleteItem(String id, String listId) {
    var list = getListOfId(listId);
    var index = list.items.indexWhere((e) => e.id == id);

    emit(ItemDeletedState(list.items.removeAt(index), index, listId));

    saveItems();
  }

  void updateItem(String id, GroceryItem newItem, String listId) {
    var list = getListOfId(listId);
    var index = list.items.indexWhere((e) => e.id == id);
    var oldItem = list.items[index];
    var updatedChecked = newItem.checked != oldItem.checked;
    var updatedProtBinding = newItem.boundPrototype?.id != oldItem.boundPrototype?.id;
    list.items[index] = newItem;

    emit(ItemsChangedState({id, oldItem.id}, updatedProtBinding));
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

class WithinListState extends GroceryListState
{
  final String listId;

  WithinListState(this.listId);

  @override
  List<Object> get props => super.props..add(listId);
}

class ItemsChangedState extends GroceryListState {
  final Set<String> changedIds;
  final bool reboundPrototype;

  ItemsChangedState(this.changedIds, this.reboundPrototype);

  @override
  List<Object> get props => super.props..add(changedIds)..add(reboundPrototype);

  bool contains(String id) => changedIds.contains(id);
}

class CheckedChangedState extends GroceryListState {
  final bool checked;
  final GroceryItem item;

  CheckedChangedState(this.checked, this.item);

  @override
  List<Object> get props => super.props..add(checked)..add(item);
}

class ItemDeletedState extends WithinListState {
  final GroceryItem removedItem;
  final int index;

  ItemDeletedState(this.removedItem, this.index, String listId) : super(listId);

  @override
  List<Object> get props => super.props..add(removedItem);
}

class ItemCreatedState extends WithinListState {
  final String id;
  final List<GroceryItem> items;

  ItemCreatedState(this.id, this.items, String listId) : super(listId);

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

class ItemMovedState extends WithinListState {
  final List<GroceryItem> items;

  ItemMovedState(this.items, String listId) : super(listId);

  @override
  List<Object> get props => super.props..add(items);
}

