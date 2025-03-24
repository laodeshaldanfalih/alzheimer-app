import 'package:flutter/material.dart';
import 'package:project/dump/dimension.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    required this.extendedBody,
  });

  final Widget mobileBody;
  final Widget extendedBody;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < mobileWidth ) {
        return mobileBody;
      } else {
        return extendedBody;
      }
    });
  }
}
