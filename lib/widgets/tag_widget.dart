import 'package:flutter/material.dart';
import 'package:grocery_list/models/item_tag.dart';

class TagWidget extends StatelessWidget {
  final BorderRadius borderRadius;
  final List<ItemTag> tags;

  const TagWidget({
    Key key,
    this.borderRadius,
    this.tags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.extent(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      physics: NeverScrollableScrollPhysics(),
      maxCrossAxisExtent: 10,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      children: tags
          .map(
            (e) => ClipRRect(
              borderRadius: borderRadius ?? BorderRadius.circular(3),
              child: ColoredBox(
                color: e.color,
                child: SizedBox.expand(),
              ),
            ),
          )
          .toList(),
    );
  }
}
