import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/grocery_list.dart';
import 'package:grocery_list/models/grocery_prototype.dart';
import 'package:grocery_list/utils/naming_utils.dart';
import 'package:grocery_list/widgets/grocery_list_items_expansion_controller.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:grocery_list/widgets/lists_view_item.dart';
import 'package:grocery_list/widgets/product_item.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:my_utilities/color_utils.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key key}) : super(key: key);

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> with AutomaticKeepAliveClientMixin<ProductsScreen> {
  HeroController _heroController;
  CardExpansionController _expansionController;

  @override
  void initState() {
    _heroController = HeroController();
    _expansionController = CardExpansionController();

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
                    buildWhen: (prev, cur) => cur is ProductsListModifiedState,
                    builder: (context, state) {
                      return ImplicitlyAnimatedReorderableList<GroceryPrototype>(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10.0),
                        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        items: bloc.prototypes,
                        itemBuilder: (context, anim, model, i) {
                          return Reorderable(
                            key: ValueKey(model.id),
                            child: ScaleTransition(
                              scale: anim,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Handle(
                                  delay: Duration(milliseconds: 300),
                                  child: ProductListItem(
                                    expansionController: _expansionController,
                                    fallbackModel: model,
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
                      message: "Create new product",
                      child: HeavyTouchButton(
                        onPressed: () async => bloc.addPrototype(
                            GroceryPrototype(title: "New Product " + findNextUnusedNumberForName("New Product", bloc.prototypes.map((e) => e.title.trim()).toList()).toString())),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent.withRangedHsvValue(0.8),
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
