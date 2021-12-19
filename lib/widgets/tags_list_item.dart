import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/item_tag.dart';
import 'package:grocery_list/screens/color_picker_dialog.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:grocery_list/widgets/smart_text_field.dart';

class TagsListItem extends StatelessWidget {
  final ItemTag fallbackModel;
  final String listId;

  const TagsListItem({
    Key key,
    this.fallbackModel,
    this.listId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var bloc = GroceryListBloc.of(context);

    return BlocBuilder<GroceryListBloc, GroceryListState>(
        cubit: bloc,
        buildWhen: (previous, current) => current is ItemTagChangedState && current.id == fallbackModel.id && current.listId == listId,
        builder: (context, state) {
          var model = bloc.getTagOfId(fallbackModel.id, listId) ?? fallbackModel;

          return Row(
            children: [
              Expanded(
                child: SmartTextField(
                  controller: TextEditingController(text: model.title),
                  decoration: InputDecoration(border: InputBorder.none),
                  focusNode: FocusNode(),
                  onEditingComplete: (state) => bloc.updateItemTag(model.id, model.copyWith(title: state.controller.text), listId),
                ),
              ),
              Spacer(),
              SizedBox(width: 20),
              HeavyTouchButton(
                onPressed: () => Navigator.of(context).push(ColorPickerDialog(
                  availableColors: bloc.presetTagColors,
                  colorsInARow: 3,
                  pickedColor: model.color,
                  onPickedColorChanged: (val) => bloc.updateItemTag(model.id, model.copyWith(color: val), listId),
                )),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: model.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SizedBox(width: 40, height: 25),
                ),
              ),
            ],
          );
        });
  }
}
