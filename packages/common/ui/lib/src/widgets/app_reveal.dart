import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class AppReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double beginOffsetY;
  final double beginScale;

  const AppReveal({
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.medium,
    this.curve = AppMotion.emphasized,
    this.beginOffsetY = 0.06,
    this.beginScale = 0.98,
    super.key,
  });

  @override
  State<AppReveal> createState() => _AppRevealState();
}

class _AppRevealState extends State<AppReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.beginOffsetY),
      end: Offset.zero,
    ).animate(curved);
    _scale = Tween<double>(begin: widget.beginScale, end: 1).animate(curved);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _delayTimer = Timer(widget.delay, _controller.forward);
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}
