import 'package:flutter/widgets.dart';

class UnfocusOnTap extends StatelessWidget {
  final Widget child;

  const UnfocusOnTap({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:() => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
