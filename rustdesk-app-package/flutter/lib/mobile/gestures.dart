import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum GestureType {
  tap,
  doubleTap,
  longPress,
  pan,
  scale,
  rotate,
  pinch,
}

class RemoteGestureConfig {
  final bool enableDoubleTap;
  final bool enableLongPress;
  final bool enablePinchZoom;
  final bool enableRotation;
  final double panSensitivity;
  final double scaleSensitivity;
  final double rotationSensitivity;

  const RemoteGestureConfig({
    this.enableDoubleTap = true,
    this.enableLongPress = true,
    this.enablePinchZoom = true,
    this.enableRotation = true,
    this.panSensitivity = 1.0,
    this.scaleSensitivity = 1.0,
    this.rotationSensitivity = 1.0,
  });
}

class GestureMapping {
  final GestureType gesture;
  final Map<String, dynamic> action;
  final int priority;

  GestureMapping({
    required this.gesture,
    required this.action,
    this.priority = 0,
  });
}

class RemoteGestureHandler {
  final RemoteGestureConfig config;
  final List<GestureMapping> customMappings;

  RemoteGestureHandler({
    this.config = const RemoteGestureConfig(),
    this.customMappings = const [],
  });

  GestureRecognizer createGestureRecognizer() {
    return MultiDragGestureRecognizer();
  }

  Map<String, dynamic> mapGestureToAction(GestureType type, Map<dynamic, dynamic> details) {
    switch (type) {
      case GestureType.tap:
        return _mapTapAction(details);
      case GestureType.doubleTap:
        return _mapDoubleTapAction(details);
      case GestureType.longPress:
        return _mapLongPressAction(details);
      case GestureType.pan:
        return _mapPanAction(details);
      case GestureType.scale:
        return _mapScaleAction(details);
      case GestureType.rotate:
        return _mapRotateAction(details);
      case GestureType.pinch:
        return _mapPinchAction(details);
    }
  }

  Map<String, dynamic> _mapTapAction(Map<dynamic, dynamic> details) {
    return {
      'type': 'mouse_click',
      'button': 'left',
      'x': details['x'] ?? 0,
      'y': details['y'] ?? 0,
    };
  }

  Map<String, dynamic> _mapDoubleTapAction(Map<dynamic, dynamic> details) {
    return {
      'type': 'mouse_click',
      'button': 'left',
      'count': 2,
      'x': details['x'] ?? 0,
      'y': details['y'] ?? 0,
    };
  }

  Map<String, dynamic> _mapLongPressAction(Map<dynamic, dynamic> details) {
    return {
      'type': 'mouse_click',
      'button': 'right',
      'x': details['x'] ?? 0,
      'y': details['y'] ?? 0,
    };
  }

  Map<String, dynamic> _mapPanAction(Map<dynamic, dynamic> details) {
    return {
      'type': 'mouse_move',
      'dx': (details['dx'] ?? 0) * config.panSensitivity,
      'dy': (details['dy'] ?? 0) * config.panSensitivity,
    };
  }

  Map<String, dynamic> _mapScaleAction(Map<dynamic, dynamic> details) {
    return {
      'type': 'mouse_scroll',
      'scale': details['scale'] ?? 1.0,
      'x': details['x'] ?? 0,
      'y': details['y'] ?? 0,
    };
  }

  Map<String, dynamic> _mapRotateAction(Map<dynamic, dynamic> details) {
    return {
      'type': 'keyboard',
      'action': 'rotate',
      'angle': (details['angle'] ?? 0) * config.rotationSensitivity,
    };
  }

  Map<String, dynamic> _mapPinchAction(Map<dynamic, dynamic> details) {
    return {
      'type': 'zoom',
      'scale': details['scale'] ?? 1.0,
      'x': details['x'] ?? 0,
      'y': details['y'] ?? 0,
    };
  }
}

class AIShortcutGestureRecognizer extends GestureRecognizer {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  VoidCallback? onTripleTap;
  VoidCallback? onDoubleTapLongPress;

  static const int tripleTapThreshold = 3;
  static const Duration tapTimeout = Duration(milliseconds: 300);
  static const Duration longPressTimeout = Duration(milliseconds: 500);

  @override
  void addPointer(PointerDownEvent event) {
    final now = DateTime.now();

    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < tapTimeout) {
      _tapCount++;
    } else {
      _tapCount = 1;
    }

    _lastTapTime = now;

    if (_tapCount >= tripleTapThreshold) {
      resolve(GestureDisposition.accepted);
      onTripleTap?.call();
      _tapCount = 0;
    }
  }

  @override
  String get debugDescription => 'ai_shortcut_gesture';

  @override
  void acceptGesture(int pointer) {}

  @override
  void rejectGesture(int pointer) {}
}