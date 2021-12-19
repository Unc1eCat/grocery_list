import 'package:flutter/material.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/screens/fly_in_dialog_window.dart';
import 'package:grocery_list/widgets/action_button.dart';
import 'package:grocery_list/widgets/beautiful_text_field.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
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
  GlobalKey deleteButton = GlobalKey();

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
                "Title",
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
                      controller: TextEditingController(text: bloc.getListOfId(widget.listId).title),
                      focusNode: FocusNode(),
                      onEditingComplete: (state) {
                        bloc.updateList(widget.listId, bloc.getListOfId(widget.listId).copyWith(title: state.controller.text));
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
          SizedBox(height: 20),
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
                      controller: TextEditingController(text: bloc.getListOfId(widget.listId).defaultCurrency),
                      focusNode: FocusNode(),
                      onEditingComplete: (state) {
                        bloc.updateList(widget.listId, bloc.getListOfId(widget.listId).copyWith(defaultCurrency: state.controller.text));
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
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
            child: Wrap(
              runSpacing: 10,
              alignment: WrapAlignment.start,
              spacing: 8,
              children: [
                ActionButton(
                  key: deleteButton,
                  onPressed: () {
                    var renderBox = deleteButton.currentContext.findRenderObject() as RenderBox;
                    var sourceOffset = renderBox.localToGlobal(Offset.zero);
                    return Navigator.of(context, rootNavigator: true).push(
                      FlyFromPointDialog(
                        sourcePosition: sourceOffset,
                        child: Placeholder(
                          // child: Align(
                          //   alignment: Alignment.center,
                          //   child: Card(
                          //     margin: EdgeInsets.all(40.0),
                          //     child: Padding(
                          //       padding: const EdgeInsets.all(10.0),
                          //       child: Column(
                          //         mainAxisSize: MainAxisSize.min,
                          //         children: [
                          //           Text("Are you sure that you want to delete this list FOREVER? This action CANNOT BE UNDONE.\nYou can archive list instead of deleting it."),
                          //           SizedBox(height: 30),
                          //           Row(
                          //             mainAxisSize: MainAxisSize.min,
                          //             crossAxisAlignment: CrossAxisAlignment.start,
                          //             children: [
                          //               HeavyTouchButton(
                          //                 onPressed: () => bloc.removeList(widget.listId),
                          //                 child: Text("Delete"),
                          //               ),
                          //               SizedBox(width: 20),
                          //               HeavyTouchButton(
                          //                 onPressed: () {}, // TODO: Archive
                          //                 child: Text("Archive"),
                          //               ),
                          //               SizedBox(width: 20),
                          //               HeavyTouchButton(
                          //                 onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                          //                 child: Text("Cancel"),
                          //               ),
                          //             ],
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ),
                      ),
                    );
                  },
                  color: Colors.red[600],
                  icon: Icons.delete_rounded,
                  title: "Delete",
                ),
                ActionButton(
                  onPressed: () {},
                  color: Colors.greenAccent[700],
                  icon: Icons.archive_rounded,
                  title: "Archive",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
