import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:insurflow/core/config/app_config.dart';
import 'package:insurflow/core/network/token_store.dart';
import 'package:insurflow/core/services/adjuster_position_store.dart';

class DioFactory {
  DioFactory._();

  static Dio create({
    required TokenStore tokenStore,
    AdjusterPositionStore? positionStore,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.data is FormData) {
            options.headers.remove(Headers.contentTypeHeader);
          }
          final token = await tokenStore.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // The backend reads the adjuster's current position off
          // ordinary requests. The headers are omitted entirely until
          // the device has produced a real fix.
          options.headers.addAll(positionStore?.headers ?? const {});
          handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (object) {
            final line = object.toString();
            if (line.contains('Authorization') || line.contains('Bearer ')) {
              return;
            }
            debugPrint(line);
          },
        ),
      );
    }

    return dio;
  }
}
