import 'package:flutter/material.dart';

class TiltCard extends StatefulWidget {
  final Widget child;
  final double depth;

  const TiltCard({
    super.key,
    required this.child,
    this.depth = 20.0,
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  double x = 0;
  double y = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          y = y - details.delta.dx / 100;
          x = x + details.delta.dy / 100;
        });
      },
      onPanEnd: (details) {
        setState(() {
          x = 0;
          y = 0;
        });
      },
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspective
          ..rotateX(x * (widget.depth / 100))
          ..rotateY(y * (widget.depth / 100)),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
