import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constant/app_constant.dart';
import '../utils/pref_service.dart';
import 'log_event_manager.dart';

class ApiService {
  static const Duration timeoutDuration = Duration(seconds: 30);
  static const JsonEncoder _prettyEncoder = JsonEncoder.withIndent('  ');

  static final http.Client _persistentClient = http.Client();

  // Common Headers
  static Map<String, String> _getHeaders({
    Map<String, String>? extraHeaders,
    bool requiresAuth = true,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'x-platform': !kIsWeb && Platform.isIOS ? 'ios' : 'android',
      'x-app-version': appVersion,
    };

    if (requiresAuth) {
      final token = PrefService.getString(PrefService.accessToken);
      if (token.isNotEmpty) {
        headers['Authorization'] =
            token.startsWith('Bearer ') ? token : 'Bearer $token';
      }
    }

    final deviceId = PrefService.getString(PrefService.deviceId);
    if (deviceId.isNotEmpty) {
      headers['x-device-id'] = deviceId;
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  // Helper to format JSON safely
  static String _prettyFormatJson(dynamic raw) {
    if (raw == null) return 'null';
    try {
      if (raw is String) {
        if (raw.trim().isEmpty) return '';
        final decoded = jsonDecode(raw);
        return _prettyEncoder.convert(decoded);
      } else if (raw is Map || raw is List) {
        return _prettyEncoder.convert(raw);
      }
    } catch (_) {
      // Return raw string if not valid JSON
    }
    return raw.toString();
  }

  // Helper to print box-style pretty log
  static void _logPrettyBox({
    required String header,
    required Map<String, dynamic> entries,
  }) {
    if (!kDebugMode) return;

    final buffer = StringBuffer();
    buffer.writeln('\n┌── $header ──────────────────────────────────────────────');

    entries.forEach((key, value) {
      if (value == null) return;
      final formatted = value is Map || value is List
          ? _prettyFormatJson(value)
          : (value.toString().contains('\n') ||
                  value.toString().startsWith('{') ||
                  value.toString().startsWith('[')
              ? _prettyFormatJson(value)
              : value.toString());

      if (formatted.contains('\n')) {
        buffer.writeln('│ $key:');
        for (final line in formatted.split('\n')) {
          buffer.writeln('│   $line');
        }
      } else {
        buffer.writeln('│ $key: $formatted');
      }
    });

    buffer.write('└──${'─' * 58}');
    debugPrint(buffer.toString());
  }

  // POST Request
  static Future<http.Response?> post({
    required String url,
    dynamic body,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final stopwatch = Stopwatch()..start();
    final finalHeaders =
        _getHeaders(extraHeaders: headers, requiresAuth: requiresAuth);
    final encodedBody =
        body != null ? (body is String ? body : jsonEncode(body)) : null;

    _logPrettyBox(
      header: '🌐 [API POST REQUEST]',
      entries: {
        'URL': url,
        'Auth': requiresAuth ? 'Bearer Token Attached' : 'None',
        'Headers': finalHeaders,
        'Body': body ?? 'None',
      },
    );

    try {
      final uri = Uri.parse(url);
      final response = await _persistentClient
          .post(uri, headers: finalHeaders, body: encodedBody)
          .timeout(timeoutDuration);

      stopwatch.stop();

      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      _logPrettyBox(
        header:
            '${isSuccess ? '📥' : '⚠️'} [API POST RESPONSE (${response.statusCode}) — ${stopwatch.elapsedMilliseconds}ms]',
        entries: {
          'URL': url,
          'Status Code': response.statusCode,
          'Duration': '${stopwatch.elapsedMilliseconds} ms',
          'Response Body': response.body,
        },
      );

      if (!isSuccess) {
        LogEventManager.logApiHttpError(
          url: url,
          method: 'POST',
          statusCode: response.statusCode,
          errorMessage: response.body,
        );
      }

      return response;
    } on SocketException catch (e) {
      stopwatch.stop();
      _logPrettyBox(
        header: '❌ [API NETWORK ERROR — SocketException]',
        entries: {
          'URL': url,
          'Duration': '${stopwatch.elapsedMilliseconds} ms',
          'Error': 'No Internet Connection or Host Unreachable: $e',
        },
      );
      LogEventManager.logApiNetworkError(
        url: url,
        method: 'POST',
        error: e.toString(),
      );
      return null;
    } on TimeoutException catch (e) {
      stopwatch.stop();
      _logPrettyBox(
        header: '❌ [API TIMEOUT ERROR — TimeoutException]',
        entries: {
          'URL': url,
          'Duration': '${stopwatch.elapsedMilliseconds} ms',
          'Error': 'Request Timed Out (${timeoutDuration.inSeconds}s): $e',
        },
      );
      LogEventManager.logApiTimeoutError(
        url: url,
        method: 'POST',
        timeoutSeconds: timeoutDuration.inSeconds,
      );
      return null;
    } catch (e) {
      stopwatch.stop();
      _logPrettyBox(
        header: '❌ [API UNKNOWN ERROR]',
        entries: {
          'URL': url,
          'Duration': '${stopwatch.elapsedMilliseconds} ms',
          'Error': e.toString(),
        },
      );
      LogEventManager.logApiUnknownError(
        url: url,
        method: 'POST',
        error: e.toString(),
      );
      return null;
    }
  }

  // GET Request
  static Future<http.Response?> get({
    required String url,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final stopwatch = Stopwatch()..start();
    final finalHeaders =
        _getHeaders(extraHeaders: headers, requiresAuth: requiresAuth);

    _logPrettyBox(
      header: '🌐 [API GET REQUEST]',
      entries: {
        'URL': url,
        'Auth': requiresAuth ? 'Bearer Token Attached' : 'None',
        'Headers': finalHeaders,
      },
    );

    try {
      final uri = Uri.parse(url);
      final response = await _persistentClient
          .get(uri, headers: finalHeaders)
          .timeout(timeoutDuration);

      stopwatch.stop();

      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      _logPrettyBox(
        header:
            '${isSuccess ? '📥' : '⚠️'} [API GET RESPONSE (${response.statusCode}) — ${stopwatch.elapsedMilliseconds}ms]',
        entries: {
          'URL': url,
          'Status Code': response.statusCode,
          'Duration': '${stopwatch.elapsedMilliseconds} ms',
          'Response Body': response.body,
        },
      );

      if (!isSuccess) {
        LogEventManager.logApiHttpError(
          url: url,
          method: 'GET',
          statusCode: response.statusCode,
          errorMessage: response.body,
        );
      }

      return response;
    } on SocketException catch (e) {
      stopwatch.stop();
      _logPrettyBox(
        header: '❌ [API NETWORK ERROR — SocketException]',
        entries: {
          'URL': url,
          'Duration': '${stopwatch.elapsedMilliseconds} ms',
          'Error': 'No Internet Connection or Host Unreachable: $e',
        },
      );
      LogEventManager.logApiNetworkError(
        url: url,
        method: 'GET',
        error: e.toString(),
      );
      return null;
    } on TimeoutException catch (e) {
      stopwatch.stop();
      _logPrettyBox(
        header: '❌ [API TIMEOUT ERROR — TimeoutException]',
        entries: {
          'URL': url,
          'Duration': '${stopwatch.elapsedMilliseconds} ms',
          'Error': 'Request Timed Out (${timeoutDuration.inSeconds}s): $e',
        },
      );
      LogEventManager.logApiTimeoutError(
        url: url,
        method: 'GET',
        timeoutSeconds: timeoutDuration.inSeconds,
      );
      return null;
    } catch (e) {
      stopwatch.stop();
      _logPrettyBox(
        header: '❌ [API UNKNOWN ERROR]',
        entries: {
          'URL': url,
          'Duration': '${stopwatch.elapsedMilliseconds} ms',
          'Error': e.toString(),
        },
      );
      LogEventManager.logApiUnknownError(
        url: url,
        method: 'GET',
        error: e.toString(),
      );
      return null;
    }
  }

  // Multipart POST Request (for File/Image Uploads)
  static Future<http.Response?> multipartPost({
    required String url,
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final stopwatch = Stopwatch()..start();
    final baseHeaders =
        _getHeaders(extraHeaders: headers, requiresAuth: requiresAuth);
    // Remove Content-Type so multipart boundary is generated automatically
    baseHeaders.remove('Content-Type');

    final deviceId = PrefService.getString(PrefService.deviceId);
    if (deviceId.isNotEmpty && !baseHeaders.containsKey('X-Device-Id')) {
      baseHeaders['X-Device-Id'] = deviceId;
    }

    _logPrettyBox(
      header: '🌐 [API MULTIPART POST REQUEST]',
      entries: {
        'URL': url,
        'Auth': requiresAuth ? 'Bearer Token Attached' : 'None',
        'Headers': baseHeaders,
        'Fields': fields,
        'Files': files
            .map((f) => '${f.field}: ${f.filename} (${f.length} bytes)')
            .toList(),
      },
    );

    try {
      final uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(baseHeaders);
      request.fields.addAll(fields);
      request.files.addAll(files);

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      stopwatch.stop();

      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      _logPrettyBox(
        header:
            '${isSuccess ? '📥' : '⚠️'} [API MULTIPART POST RESPONSE (${response.statusCode}) — ${stopwatch.elapsedMilliseconds}ms]',
        entries: {
          'URL': url,
          'Status Code': response.statusCode,
          'Duration': '${stopwatch.elapsedMilliseconds} ms',
          'Response Body': response.body,
        },
      );

      if (!isSuccess) {
        LogEventManager.logApiHttpError(
          url: url,
          method: 'MULTIPART_POST',
          statusCode: response.statusCode,
          errorMessage: response.body,
        );
      }

      return response;
    } on SocketException catch (e) {
      stopwatch.stop();
      _logPrettyBox(
        header: '❌ [API NETWORK ERROR — SocketException]',
        entries: {
          'URL': url,
          'Duration': '${stopwatch.elapsedMilliseconds} ms',
          'Error': 'No Internet Connection or Host Unreachable: $e',
        },
      );
      LogEventManager.logApiNetworkError(
        url: url,
        method: 'MULTIPART_POST',
        error: e.toString(),
      );
      return null;
    } on TimeoutException catch (e) {
      stopwatch.stop();
      _logPrettyBox(
        header: '❌ [API TIMEOUT ERROR — TimeoutException]',
        entries: {
          'URL': url,
          'Duration': '${stopwatch.elapsedMilliseconds} ms',
          'Error': 'Request Timed Out (60s): $e',
        },
      );
      LogEventManager.logApiTimeoutError(
        url: url,
        method: 'MULTIPART_POST',
        timeoutSeconds: 60,
      );
      return null;
    } catch (e) {
      stopwatch.stop();
      _logPrettyBox(
        header: '❌ [API UNKNOWN ERROR]',
        entries: {
          'URL': url,
          'Duration': '${stopwatch.elapsedMilliseconds} ms',
          'Error': e.toString(),
        },
      );
      LogEventManager.logApiUnknownError(
        url: url,
        method: 'MULTIPART_POST',
        error: e.toString(),
      );
      return null;
    }
  }
}

