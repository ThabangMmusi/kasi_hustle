import 'package:flutter/material.dart';

class HomeStatusBarGradient extends StatelessWidget {
  const HomeStatusBarGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 80,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.2, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
