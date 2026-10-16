import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:sri_murugan_chits/services/api/storage_service.dart';

import 'api_constants.dart';

class ApiService {
  late final Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        // ========================================================
        // REQUEST
        // ========================================================

        onRequest: (options, handler) async {
          final token = await StorageService.getToken();

          debugPrint("========================================");
          debugPrint("API REQUEST");
          debugPrint("METHOD : ${options.method}");
          debugPrint("URL    : ${options.uri}");
          debugPrint(
            "TOKEN EXISTS : ${token != null && token.isNotEmpty}",
          );

          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] =
                "Bearer $token";

            debugPrint("AUTHORIZATION : Bearer <TOKEN>");
          } else {
            debugPrint("AUTHORIZATION : NOT ADDED");
          }

          debugPrint("REQUEST DATA : ${options.data}");
          debugPrint("========================================");

          return handler.next(options);
        },

        // ========================================================
        // ERROR
        // ========================================================

        onError: (DioException error, handler) async {
          debugPrint("========================================");
          debugPrint("API ERROR");
          debugPrint("METHOD : ${error.requestOptions.method}");
          debugPrint("URL    : ${error.requestOptions.uri}");
          debugPrint(
            "STATUS : ${error.response?.statusCode}",
          );
          debugPrint(
            "RESPONSE : ${error.response?.data}",
          );
          debugPrint("========================================");

          if (error.response?.statusCode == 401) {
            await StorageService.logout();

            debugPrint(
              "TOKEN CLEARED BECAUSE SERVER RETURNED 401",
            );
          }

          return handler.next(error);
        },
      ),
    );
  }

  // ============================================================
  // GET
  // ============================================================

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio.get(
      url,
      queryParameters: queryParameters,
    );
  }

  // ============================================================
  // POST
  // ============================================================

  Future<Response> post(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio.post(
      url,
      data: data,
      queryParameters: queryParameters,
    );
  }

  // ============================================================
  // PUT
  // ============================================================

  Future<Response> put(
    String url, {
    Map<String, dynamic>? data,
  }) async {
    return await dio.put(
      url,
      data: data,
    );
  }

  // ============================================================
  // PATCH
  // ============================================================

  Future<Response> patch(
    String url, {
    Map<String, dynamic>? data,
  }) async {
    return await dio.patch(
      url,
      data: data,
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<Response> delete(
    String url, {
    Map<String, dynamic>? data,
  }) async {
    return await dio.delete(
      url,
      data: data,
    );
  }

  // ============================================================
  // MULTIPART POST
  // ============================================================

  Future<Response> postMultipart(
    String url,
    FormData formData,
  ) async {
    return await dio.post(
      url,
      data: formData,
      options: Options(
        contentType: "multipart/form-data",
      ),
    );
  }

  // ============================================================
  // MULTIPART PUT
  // ============================================================

  Future<Response> putMultipart(
    String url,
    FormData formData,
  ) async {
    return await dio.put(
      url,
      data: formData,
      options: Options(
        contentType: "multipart/form-data",
      ),
    );
  }
}