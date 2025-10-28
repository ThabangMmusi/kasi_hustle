import 'package:flutter/material.dart';

class LoginBackground extends StatelessWidget {
  final Animation<double> animation;

  const LoginBackground({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        // Smoother transition: from 100% to 70%
        final heightPercent = 1.0 - (animation.value * 0.3);
        final backgroundHeight = screenHeight * heightPercent;

        return Column(
          children: [
            SizedBox(
              height: backgroundHeight,
              width: double.infinity,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/login_bg.png'),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Expanded(child: Container(color: Colors.black)),
          ],
        );
      },
    );
  }
}
