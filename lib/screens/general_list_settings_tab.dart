import 'package:flutter/material.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/widgets/beautiful_text_field.dart';
import 'package:grocery_list/widgets/smart_text_field.dart';
import 'package:grocery_list/widgets/unfocus_on_tap.dart';

class GeneralListSettingsTab extends StatefulWidget {
  final ScrollController scrollController;
  final String listId;

  const GeneralListSettingsTab({Key key, this.scrollController, this.listId}) : super(key: key);

  @override
  State<GeneralListSettingsTab> createState() => _GeneralListSettingsTabState();
}

class _GeneralListSettingsTabState extends State<GeneralListSettingsTab> {
  @override
  Widget build(BuildContext context) {
    var bloc = GroceryListBloc.of(context);

    return UnfocusOnTap(
      child: ListView(
        controller: widget.scrollController,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 64, left: 20, right: 20),
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        children: [
          Row(
            children: [
              Text(
                "Default currency",
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(width: 20),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color.fromRGBO(30, 30, 30, 0.6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: SmartTextField(
                      controller: TextEditingController(text: bloc.getListOfId(widget.listId).default_currency),
                      focusNode: FocusNode(),
                      onEditingComplete: (state) {
                        bloc.updateList(widget.listId, bloc.getListOfId(widget.listId).copyWith(default_currency: state.controller.text));
                      },
                      onSubmitted: (_) {
                        FocusScope.of(context).unfocus();
                      },
                      decoration: InputDecoration(border: InputBorder.none),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
