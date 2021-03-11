import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:grocery_list/models/item_tag.dart';

class GroceryListBloc extends Cubit<GroceryListState> {
  List<GroceryItem> _items = [GroceryItem()];
  List<GroceryItem> get items => List.unmodifiable(_items);

  GroceryListBloc(this._items) : super(GroceryListState());

  void updateItem(int index, GroceryItem newItem)
  {
    _items[index] = newItem;

    emit(ItemChangedState(List.unmodifiable(_items), index));
  }
}

// STATEs

class GroceryListState extends Equatable {
  @override
  List<Object> get props => [];
}

class ItemChangedState extends GroceryListState {
  final List<GroceryItem> items;
  final int index;

  ItemChangedState(this.items, this.index);

  @override
  List<Object> get props => super.props..add(items)..add(index);
}
