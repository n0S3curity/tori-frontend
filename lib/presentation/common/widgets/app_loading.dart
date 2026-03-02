import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(),
      );
}

class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({required this.child, required this.isLoading, super.key});

  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          child,
          if (isLoading)
            const ColoredBox(
              color: Colors.black26,
              child: AppLoading(),
            ),
        ],
      );
}
