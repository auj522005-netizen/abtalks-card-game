import 'package:flutter/material.dart';

class PulseWidget extends AnimatedWidget {
  final Widget child;

  const PulseWidget({super.key, required Animation<double> animation, required this.child}) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final v = (listenable as Animation<double>).value;
    return Opacity(opacity: 0.7 + v * 0.3, child: Transform.scale(scale: 1.0 + v * 0.05, child: child));
  }
}
