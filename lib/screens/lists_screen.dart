import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/grocery_list.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:grocery_list/widgets/lists_view_item.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:my_utilities/color_utils.dart';

class ListsScreen extends StatefulWidget {
  const ListsScreen({Key key}) : super(key: key);

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> with AutomaticKeepAliveClientMixin<ListsScreen> {
  HeroController _heroController;

  @override
  void initState() {
    _heroController = HeroController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var bloc = GroceryListBloc.of(context);
    var navigatorKey = GlobalKey<NavigatorState>();

    return WillPopScope(
      onWillPop: () async {
        navigatorKey.currentState.maybePop();
        return false;
      },
      child: Navigator(
        key: navigatorKey,
        observers: [_heroController],
        onGenerateInitialRoutes: (navigator, initialRoute) => [
          MaterialPageRoute(
            builder: (context) => Material(
              type: MaterialType.transparency,
              child: Stack(
                children: [
                  BlocBuilder<GroceryListBloc, GroceryListState>(
                    cubit: bloc,
                    buildWhen: (prev, cur) => cur is ListsListModifiedState,
                    builder: (context, state) {
                      return ImplicitlyAnimatedReorderableList<GroceryList>(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10.0, left: 10.0, right: 10.0),
                        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        items: bloc.lists,
                        itemBuilder: (context, anim, item, i) {
                          return Reorderable(
                            key: ValueKey(item.id),
                            child: ScaleTransition(
                              scale: anim,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Handle(
                                  delay: Duration(milliseconds: 300),
                                  child: ListsViewItem(
                                    id: item.id,
                                    bloc: bloc,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        areItemsTheSame: (a, b) => a.id == b.id,
                        onReorderFinished: (id, from, to, newItems) => bloc.moveList(from, to),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 20,
                    right: 30,
                    child: Tooltip(
                      message: "Create new grocery list",
                      child: HeavyTouchButton(
                        onPressed: () async => bloc.addList(GroceryList(title: "New List")),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.limeAccent[700].withRangedHsvValue(0.8),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.add_rounded,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
        onPopPage: (_, __) => true,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
