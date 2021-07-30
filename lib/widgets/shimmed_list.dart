import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmedList extends StatelessWidget {
  final Widget child;

  const ShimmedList({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemBuilder: (_, __) => Shimmer.fromColors(
          child: child,
          baseColor: Colors.grey,
          highlightColor: Colors.grey,
        ),
        itemCount: 10,
      );
}
