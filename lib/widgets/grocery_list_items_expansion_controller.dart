import 'package:flutter/cupertino.dart';

class CardExpansionController extends ChangeNotifier
{
  String _expandedGroceryListItemDetails = null;

  String get expandedCardItemId => _expandedGroceryListItemDetails;

  set expandedCardItemId(String val) {
    _expandedGroceryListItemDetails = val;
    notifyListeners();
  }
}