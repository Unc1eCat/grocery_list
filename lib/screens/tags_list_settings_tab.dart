import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/item_tag.dart';
import 'package:grocery_list/utils/modeling_utils.dart';
import 'package:grocery_list/widgets/beautiful_text_field.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:grocery_list/widgets/smart_text_field.dart';
import 'package:grocery_list/widgets/tags_list_item.dart';
import 'package:grocery_list/widgets/unfocus_on_tap.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:my_utilities/color_utils.dart';

class TagsListSettingsTab extends StatefulWidget {
  final ScrollController scrollController;
  final String listId;

  const TagsListSettingsTab({Key key, this.scrollController, this.listId}) : super(key: key);

  @override
  State<TagsListSettingsTab> createState() => _TagsListSettingsTabState();
}

class _TagsListSettingsTabState extends State<TagsListSettingsTab> {
  var list = GlobalKey<ImplicitlyAnimatedReorderableListState>();

  @override
  Widget build(BuildContext context) {
    var bloc = GroceryListBloc.of(context);
    var length = bloc.getListOfId(widget.listId).tags.length;

    return UnfocusOnTap(
      child: BlocBuilder<GroceryListBloc, GroceryListState>(
        cubit: bloc,
        buildWhen: (previous, current) => current is ItemTagsListModifiedState && current.listId == widget.listId,
        builder: (context, state) => ImplicitlyAnimatedReorderableList<ItemTag>(
          key: list,
          controller: widget.scrollController,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 64, left: 20, right: 20, bottom: 20.0),
          physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          items: bloc.getListOfId(widget.listId).tags,
          areItemsTheSame: (a, b) => a.id == b.id,
          onReorderFinished: (item, from, to, newItems) => bloc.moveItemTag(from, to, widget.listId),
          footer: Align(
            alignment: Alignment.topCenter,
            child: HeavyTouchButton(
              onPressed: () async => bloc.addItemTag(
                  ItemTag(
                      color: (bloc.getUnoccupiedTagColors(widget.listId).toList()..shuffle()).first,
                      title: "New Tag " + findNextUnusedNumberForName("New Tag", bloc.getListOfId(widget.listId).tags.map((e) => e.title).toList()).toString()),
                  widget.listId),
              child: Text(
                "+  Create new tag",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
          itemBuilder: (context, animation, model, i) => Reorderable(
            key: ValueKey(model.id),
            child: Handle(
              delay: Duration(milliseconds: 700),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: TagsListItem(
                      fallbackModel: model,
                      listId: widget.listId,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
