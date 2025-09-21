import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WalkingSneaker extends StatefulWidget {
  final double width;
  const WalkingSneaker({super.key, this.width = 200});

  @override
  State<WalkingSneaker> createState() => _WalkingSneakerState();
}

class _WalkingSneakerState extends State<WalkingSneaker>
    with SingleTickerProviderStateMixin {
  late AnimationController _walkController;
  late Animation<Offset> _walkAnimation;

  @override
  void initState() {
    super.initState();
    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _walkAnimation =
        Tween<Offset>(
          begin: const Offset(-1.5, 0),
          end: const Offset(1.5, 0),
        ).animate(
          CurvedAnimation(parent: _walkController, curve: Curves.easeInOut),
        );

    _walkController.repeat();
  }

  @override
  void dispose() {
    _walkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _walkAnimation,
      child: Lottie.asset(
        'assets/animations/sneaker_animation3.json',
        width: widget.width,
        fit: BoxFit.contain,
      ),
    );
  }
}
