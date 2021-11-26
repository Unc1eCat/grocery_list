import 'dart:ui';

import 'package:flutter/material.dart';

@Deprecated("Incomplete, draft")
class FrostedGlassCard extends StatelessWidget {
  const FrostedGlassCard({ Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2));
  }
}