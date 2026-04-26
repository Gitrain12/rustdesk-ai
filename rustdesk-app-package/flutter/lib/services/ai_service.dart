import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AIConstants {
  static const String apiBaseUrl = 'http://10.0.2.2:8080/api/ai';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
}

class AIResponse {
  final bool success;
  final String? result;
  final String? error;
  final Duration processingTime;
  final Map<String, dynamic>? rawResult;

  AIResponse({
    required this.success,
    this.result,
    this.error,
    required this.processingTime,
    this.rawResult,
  });
}

class AIService extends ChangeNotifier {
  bool _isProcessing = false;
  String? _lastError;
  String? _currentFeature;

  static const String _baseUrl = AIConstants.apiBaseUrl;

  bool get isProcessing => _isProcessing;
  String? get lastError => _lastError;
  String? get currentFeature => _currentFeature;

  Future<AIResponse> _makeRequest(
    String endpoint, {
    Map<String, dynamic>? body,
    Uint8List? imageData,
  }) async {
    _isProcessing = true;
    _currentFeature = endpoint;
    _lastError = null;
    notifyListeners();

    final stopwatch = Stopwatch()..start();

    try {
      final uri = Uri.parse('$_baseUrl/$endpoint');
      final requestBody = <String, dynamic>{};

      if (body != null) {
        requestBody.addAll(body);
      }

      http.Response response;

      if (imageData != null) {
        final multipartRequest = http.MultipartRequest('POST', uri);
        multipartRequest.fields['params'] = jsonEncode(requestBody);
        multipartRequest.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageData,
            filename: 'image.jpg',
          ),
        );

        final streamedResponse = await multipartRequest.send().timeout(
          AIConstants.requestTimeout,
        );
        response = await http.Response.fromStream(streamedResponse);
      } else {
        response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        ).timeout(AIConstants.requestTimeout);
      }

      stopwatch.stop();

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _isProcessing = false;
        notifyListeners();

        if (json['success'] == true) {
          String? resultText;

          if (endpoint == 'chat') {
            resultText = json['result']?['response'];
          } else if (endpoint == 'translate') {
            resultText = json['result']?['translated'];
          } else if (endpoint == 'ocr') {
            resultText = json['result']?['text'];
          } else if (endpoint == 'code-review') {
            resultText = json['result']?['review'];
          } else if (endpoint == 'summarize') {
            resultText = json['result']?['summary'];
          }

          return AIResponse(
            success: true,
            result: resultText ?? json['result']?.toString(),
            processingTime: stopwatch.elapsed,
            rawResult: json['result'],
          );
        } else {
          return AIResponse(
            success: false,
            error: json['error'] ?? 'Unknown error',
            processingTime: stopwatch.elapsed,
          );
        }
      } else {
        _isProcessing = false;
        _lastError = 'HTTP ${response.statusCode}';
        notifyListeners();
        return AIResponse(
          success: false,
          error: 'HTTP ${response.statusCode}',
          processingTime: stopwatch.elapsed,
        );
      }
    } catch (e) {
      stopwatch.stop();
      _isProcessing = false;
      _lastError = e.toString();
      notifyListeners();
      return AIResponse(
        success: false,
        error: e.toString(),
        processingTime: stopwatch.elapsed,
      );
    }
  }

  Future<AIResponse> performOCR(Uint8List imageData) async {
    return await _makeRequest(
      'ocr',
      imageData: imageData,
    );
  }

  Future<AIResponse> smartChat(String message, {Uint8List? contextImage}) async {
    final body = {'message': message};

    if (contextImage != null) {
      return await _makeRequest(
        'chat/with-context',
        body: body,
        imageData: contextImage,
      );
    }

    return await _makeRequest('chat', body: body);
  }

  Future<AIResponse> analyzeCode(Uint8List imageData) async {
    return await _makeRequest(
      'code-review',
      imageData: imageData,
    );
  }

  Future<AIResponse> summarizeContent(Uint8List imageData) async {
    return await _makeRequest(
      'summarize',
      imageData: imageData,
    );
  }

  Future<AIResponse> translateText(String text, String targetLanguage) async {
    return await _makeRequest(
      'translate',
      body: {
        'text': text,
        'target': targetLanguage,
      },
    );
  }

  void cancelCurrentOperation() {
    _isProcessing = false;
    _currentFeature = null;
    _lastError = null;
    notifyListeners();
  }
}