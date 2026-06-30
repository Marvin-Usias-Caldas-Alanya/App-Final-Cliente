import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Error de comunicación con Core Mobile API.
class CoreApiException implements Exception {
  CoreApiException(this.message);

  final String message;

  static const connectionError =
      'No se pudo conectar con Core Mobile. Verifica que FastAPI esté ejecutándose.';

  @override
  String toString() => message;
}

/// Cliente HTTP para Core Mobile API (FastAPI).
abstract final class CoreApiClient {
  static const _timeout = Duration(seconds: 15);

  static String get baseUrl {
    final raw = dotenv.env['CORE_API_URL']?.trim();
    if (raw == null || raw.isEmpty) {
      throw CoreApiException('CORE_API_URL no está configurada en .env');
    }
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  static Future<String> aprobarSolicitud(String solicitudId) async {
    final data = await _post('/solicitudes/$solicitudId/aprobar');
    return _messageFrom(data, fallback: 'Solicitud aprobada correctamente');
  }

  static Future<String> desembolsarSolicitud(String solicitudId) async {
    final data = await _post('/solicitudes/$solicitudId/desembolsar');
    return _messageFrom(data, fallback: 'Crédito desembolsado');
  }

  static Future<String> pagarCuotaDemo(String creditoId) async {
    final data = await _post('/pagos/credito/$creditoId/pagar-cuota-demo');
    return _messageFrom(data, fallback: 'Pago registrado correctamente');
  }

  static Future<Map<String, dynamic>> _post(String path) async {
    final uri = Uri.parse('$baseUrl$path');

    try {
      final response = await http.post(
        uri,
        headers: const {'Accept': 'application/json'},
      ).timeout(_timeout);

      return _parseResponse(response);
    } on TimeoutException {
      throw CoreApiException(CoreApiException.connectionError);
    } on SocketException {
      throw CoreApiException(CoreApiException.connectionError);
    } on http.ClientException {
      throw CoreApiException(CoreApiException.connectionError);
    } on CoreApiException {
      rethrow;
    } catch (e) {
      throw CoreApiException('Error inesperado al llamar al Core: $e');
    }
  }

  static Map<String, dynamic> _parseResponse(http.Response response) {
    Map<String, dynamic>? body;
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          body = decoded;
        }
      } catch (_) {
        // Respuesta no JSON; se maneja abajo.
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body ?? <String, dynamic>{};
    }

    final detail = body?['detail'];
    if (detail is String && detail.isNotEmpty) {
      throw CoreApiException(detail);
    }
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map && first['msg'] != null) {
        throw CoreApiException(first['msg'].toString());
      }
    }

    throw CoreApiException(
      'Core respondió con error ${response.statusCode}',
    );
  }

  static String _messageFrom(
    Map<String, dynamic> data, {
    required String fallback,
  }) {
    final message = data['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }
    return fallback;
  }
}
