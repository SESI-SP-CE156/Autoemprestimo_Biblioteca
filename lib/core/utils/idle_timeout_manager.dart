import 'dart:async';
import 'package:flutter/material.dart';

/// Monitors user interactions and triggers a callback after a period of inactivity.
class IdleTimeoutManager extends StatefulWidget {
  final Widget child;
  final Duration timeout;
  final VoidCallback onTimeout;
  final bool enabled;

  const IdleTimeoutManager({
    super.key,
    required this.child,
    this.timeout = const Duration(seconds: 45),
    required this.onTimeout,
    this.enabled = true,
  });

  @override
  State<IdleTimeoutManager> createState() => _IdleTimeoutManagerState();
}

class _IdleTimeoutManagerState extends State<IdleTimeoutManager> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void didUpdateWidget(covariant IdleTimeoutManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _resetTimer();
      } else {
        _timer?.cancel();
      }
    }
  }

  void _resetTimer() {
    if (!widget.enabled) return;
    _timer?.cancel();
    _timer = Timer(widget.timeout, () {
      if (mounted && widget.enabled) {
        widget.onTimeout();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
