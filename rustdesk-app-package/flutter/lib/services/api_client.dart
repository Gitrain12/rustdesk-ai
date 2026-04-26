import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../common.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class ApiClient {
  final String baseUrl;
  final http.Client _client;
  String? _authToken;
  Duration _timeout;

  ApiClient({
    required this.baseUrl,
    http.Client? client,
    Duration? timeout,
  })  : _client = client ?? http.Client(),
        _timeout = timeout ?? AIConstants.requestTimeout;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('GET request failed: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final encodedBody = jsonEncode(body ?? {});

      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: encodedBody,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('POST request failed: $e');
    }
  }

  Future<Map<String, dynamic>> postWithImage(
    String endpoint, {
    required Uint8List imageData,
    Map<String, dynamic>? params,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll(_headers);
      request.fields['params'] = jsonEncode(params ?? {});

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageData,
          filename: 'image.jpg',
        ),
      );

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('POST with image failed: $e');
    }
  }

  Future<Map<String, dynamic>> uploadFile(
    String endpoint, {
    required Uint8List fileData,
    required String filename,
    Map<String, dynamic>? params,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll(_headers);
      request.fields['params'] = jsonEncode(params ?? {});

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileData,
          filename: filename,
        ),
      );

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('File upload failed: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }

      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        return {'data': data};
      }
    } else if (response.statusCode == 401) {
      throw ApiException(
        'Unauthorized',
        statusCode: 401,
        data: response.body,
      );
    } else if (response.statusCode == 429) {
      throw ApiException(
        'Rate limit exceeded',
        statusCode: 429,
        data: response.body,
      );
    } else {
      throw ApiException(
        'Request failed',
        statusCode: response.statusCode,
        data: response.body,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

class AIServiceClient {
  final ApiClient _apiClient;

  AIServiceClient({
    required String baseUrl,
    String? authToken,
  }) : _apiClient = ApiClient(baseUrl: baseUrl) {
    if (authToken != null) {
      _apiClient.setAuthToken(authToken);
    }
  }

  void setAuthToken(String token) {
    _apiClient.setAuthToken(token);
  }

  Future<String> performOCR(Uint8List imageData) async {
    try {
      final response = await _apiClient.postWithImage(
        '/api/ai/ocr',
        imageData: imageData,
      );

      if (response['success'] == true) {
        return response['result']?['text'] ?? '';
      } else {
        throw ApiException(response['error'] ?? 'OCR failed');
      }
    } catch (e) {
      debugPrint('OCR error: $e');
      rethrow;
    }
  }

  Future<String> chat(String message, {Uint8List? imageContext}) async {
    try {
      final params = {'message': message};

      Map<String, dynamic> response;

      if (imageContext != null) {
        response = await _apiClient.postWithImage(
          '/api/ai/chat/with-context',
          imageData: imageContext,
          params: params,
        );
      } else {
        response = await _apiClient.post(
          '/api/ai/chat',
          body: params,
        );
      }

      if (response['success'] == true) {
        return response['result']?['response'] ?? '';
      } else {
        throw ApiException(response['error'] ?? 'Chat failed');
      }
    } catch (e) {
      debugPrint('Chat error: $e');
      rethrow;
    }
  }

  Future<String> codeReview(Uint8List codeImage) async {
    try {
      final response = await _apiClient.postWithImage(
        '/api/ai/code-review',
        imageData: codeImage,
      );

      if (response['success'] == true) {
        return response['result']?['review'] ?? '';
      } else {
        throw ApiException(response['error'] ?? 'Code review failed');
      }
    } catch (e) {
      debugPrint('Code review error: $e');
      rethrow;
    }
  }

  Future<String> summarize(Uint8List screenImage) async {
    try {
      final response = await _apiClient.postWithImage(
        '/api/ai/summarize',
        imageData: screenImage,
      );

      if (response['success'] == true) {
        return response['result']?['summary'] ?? '';
      } else {
        throw ApiException(response['error'] ?? 'Summarize failed');
      }
    } catch (e) {
      debugPrint('Summarize error: $e');
      rethrow;
    }
  }

  Future<Map<String, String>> translate(String text, String targetLang) async {
    try {
      final response = await _apiClient.post(
        '/api/ai/translate',
        body: {
          'text': text,
          'target': targetLang,
        },
      );

      if (response['success'] == true) {
        return {
          'original': response['result']?['original'] ?? '',
          'translated': response['result']?['translated'] ?? '',
        };
      } else {
        throw ApiException(response['error'] ?? 'Translate failed');
      }
    } catch (e) {
      debugPrint('Translate error: $e');
      rethrow;
    }
  }

  void dispose() {
    _apiClient.dispose();
  }
}