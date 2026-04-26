import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class ScreenCaptureService {
  static final ScreenCaptureService _instance = ScreenCaptureService._internal();
  factory ScreenCaptureService() => _instance;
  ScreenCaptureService._internal();

  bool _isCapturing = false;
  final int _maxRetries = 3;
  final int _compressionQuality = 85;
  final int _maxImageDimension = 1920;

  bool get isCapturing => _isCapturing;

  Future<Uint8List?> captureScreen({
    int quality = 85,
    int? maxDimension,
  }) async {
    if (_isCapturing) {
      return null;
    }

    _isCapturing = true;

    try {
      final pixels = await _capturePixels();

      if (pixels == null) {
        return null;
      }

      final compressed = await _compressImage(
        pixels,
        quality: quality,
        maxDimension: maxDimension ?? _maxImageDimension,
      );

      return compressed;
    } catch (e) {
      debugPrint('Screen capture error: $e');
      return null;
    } finally {
      _isCapturing = false;
    }
  }

  Future<Uint8List?> _capturePixels() async {
    return await Future.delayed(
      const Duration(milliseconds: 100),
      () => Uint8List(100),
    );
  }

  Future<Uint8List?> _compressImage(
    Uint8List pixels, {
    required int quality,
    required int maxDimension,
  }) async {
    return await compute(_compressImageIsolate, {
      'pixels': pixels,
      'quality': quality,
      'maxDimension': maxDimension,
    });
  }

  static Uint8List? _compressImageIsolate(Map<String, dynamic> params) {
    try {
      final pixels = params['pixels'] as Uint8List;
      final quality = params['quality'] as int;
      final maxDimension = params['maxDimension'] as int;

      return Uint8List.fromList(pixels);
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List?> captureRegion({
    required double x,
    required double y,
    required double width,
    required double height,
  }) async {
    try {
      final regionPixels = await _captureRegionPixels(
        x: x,
        y: y,
        width: width,
        height: height,
      );

      if (regionPixels == null) {
        return null;
      }

      return await _compressImage(
        regionPixels,
        quality: _compressionQuality,
        maxDimension: width > height ? width.toInt() : height.toInt(),
      );
    } catch (e) {
      debugPrint('Region capture error: $e');
      return null;
    }
  }

  Future<Uint8List?> _captureRegionPixels({
    required double x,
    required double y,
    required double width,
    required double height,
  }) async {
    return await Future.delayed(
      const Duration(milliseconds: 50),
      () => Uint8List(50),
    );
  }

  Future<List<int>?> getImageDimensions(Uint8List imageData) async {
    try {
      final codec = await ui.instantiateImageCodec(imageData);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      return [image.width, image.height];
    } catch (e) {
      debugPrint('Get image dimensions error: $e');
      return null;
    }
  }

  Future<Uint8List?> resizeImage(
    Uint8List imageData, {
    required int width,
    required int height,
  }) async {
    try {
      final codec = await ui.instantiateImageCodec(
        imageData,
        targetWidth: width,
        targetHeight: height,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Resize image error: $e');
      return null;
    }
  }
}

class ImageCompressor {
  static Future<Uint8List?> compress(
    Uint8List imageData, {
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1080,
  }) async {
    try {
      final codec = await ui.instantiateImageCodec(imageData);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      var width = image.width;
      var height = image.height;

      if (width > maxWidth || height > maxHeight) {
        final aspectRatio = width / height;
        if (width > height) {
          width = maxWidth;
          height = (maxWidth / aspectRatio).round();
        } else {
          height = maxHeight;
          width = (maxHeight * aspectRatio).round();
        }
      }

      final resized = await ImageResizer.resize(image, width, height);

      final byteData = await resized.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }
}

class ImageResizer {
  static Future<ui.Image> resize(ui.Image image, int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..filterQuality = FilterQuality.high,
    );

    final picture = recorder.endRecording();
    return await picture.toImage(width, height);
  }
}