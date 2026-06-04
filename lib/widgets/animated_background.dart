import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  List<Offset> _positions = [];
  List<Color> _colors = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _colors = [
      AppColors.primary.withValues(alpha: 0.15),
      AppColors.accent.withValues(alpha: 0.15),
      AppColors.purple.withValues(alpha: 0.15),
      Colors.blueAccent.withValues(alpha: 0.1),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_positions.isEmpty) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 4; i++) {
        _positions.add(Offset(
          _random.nextDouble() * size.width,
          _random.nextDouble() * size.height,
        ));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(color: const Color(0xFF0D0D1A)), // Base Dark Bg
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: List.generate(4, (index) {
                // Kalkulasi pergerakan lambat
                final x = _positions[index].dx +
                    sin(_controller.value * 2 * pi + index) * 50;
                final y = _positions[index].dy +
                    cos(_controller.value * 2 * pi + index) * 50;

                return Positioned(
                  left: x - 150,
                  top: y - 150,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _colors[index],
                    ),
                  ),
                );
              }),
            );
          },
        ),
        // Blur Filter untuk efek Mesh Gradient
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.transparent),
          ),
        ),
        widget.child,
      ],
    );
  }
}
