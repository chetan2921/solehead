import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class InkDropLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const InkDropLoader({super.key, this.size = 50, this.color});

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.inkDrop(
      color: color ?? Colors.white,
      size: size,
    );
  }
}

class InkDropScreen extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const InkDropScreen({
    super.key,
    this.size = 50,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: InkDropLoader(size: size, color: color),
      ),
    );
  }
}

class InkDropButton extends StatelessWidget {
  final double size;
  final Color? color;

  const InkDropButton({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: InkDropLoader(size: size, color: color),
    );
  }
}
