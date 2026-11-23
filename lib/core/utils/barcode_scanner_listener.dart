import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps a screen or widget tree to capture barcode scanner events.
/// Barcode scanners typically emulate a keyboard, rapidly typing characters
/// and submitting an Enter key at the end.
class BarcodeScannerListener extends StatefulWidget {
  final Widget child;
  final ValueChanged<String> onBarcodeScanned;
  final FocusNode? focusNode;
  final bool autoFocus;

  const BarcodeScannerListener({
    super.key,
    required this.child,
    required this.onBarcodeScanned,
    this.focusNode,
    this.autoFocus = true,
  });

  @override
  State<BarcodeScannerListener> createState() => _BarcodeScannerListenerState();
}

class _BarcodeScannerListenerState extends State<BarcodeScannerListener> {
  late final FocusNode _internalFocusNode;
  final StringBuffer _buffer = StringBuffer();
  DateTime? _lastKeystrokeTime;
  Timer? _clearTimer;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = FocusNode();
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestFocus();
      });
    }
  }

  void _requestFocus() {
    if (mounted && !_effectiveFocusNode.hasFocus) {
      _effectiveFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _clearTimer?.cancel();
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final now = DateTime.now();

    // If more than 500ms passed since last keystroke, reset buffer
    if (_lastKeystrokeTime != null && now.difference(_lastKeystrokeTime!).inMilliseconds > 500) {
      _buffer.clear();
    }
    _lastKeystrokeTime = now;

    if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      final code = _buffer.toString().trim();
      _buffer.clear();
      _clearTimer?.cancel();
      if (code.isNotEmpty) {
        widget.onBarcodeScanned(code);
      }
      return;
    }

    final char = event.character;
    if (char != null && char.isNotEmpty && !char.contains('\n') && !char.contains('\r')) {
      _buffer.write(char);
      // Auto-clear buffer if no Enter key arrives after 1.5 seconds
      _clearTimer?.cancel();
      _clearTimer = Timer(const Duration(milliseconds: 1500), () {
        _buffer.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _effectiveFocusNode,
      autofocus: widget.autoFocus,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _requestFocus,
        child: widget.child,
      ),
    );
  }
}
