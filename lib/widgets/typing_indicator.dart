import 'package:flutter/material.dart';
import 'dart:math';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double offset = (index * 0.2);
                return Transform.translate(
                  offset: Offset(
                    0,
                    sin((_controller.value * 2 * pi + offset) % 1) * 4,
                  ),
                  child: child,
                );
              },
              child: const CircleAvatar(
                radius: 4,
                backgroundColor: Colors.blue,
              ),
            ),
          );
        }),
      ),
    );
  }
} 