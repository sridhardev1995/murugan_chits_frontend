import 'package:dio/dio.dart';
import 'package:sri_murugan_chits/models/customers/customer_model.dart';
import 'package:sri_murugan_chits/services/api/api_constants.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';

class CustomerRepository {
  final ApiService _api;

  CustomerRepository(this._api);

  // ============================================================
  // GET /api/customers?page=&limit=&search=&status=
  // ============================================================

  Future<Map<String, dynamic>> getCustomers({
    int page = 1,
    int limit = 20,
    String search = '',
    String status = '',
  }) async {
    try {
      final response = await _api.get(
        ApiConstants.customers,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search.trim().isNotEmpty) 'search': search.trim(),
          if (status.trim().isNotEmpty) 'status': status.trim(),
        },
      );

      final responseData = response.data;

      if (responseData is! Map<String, dynamic>) {
        throw Exception('Invalid server response.');
      }

      final List<dynamic> list =
          responseData['data'] is List ? responseData['data'] : [];

      final customers = list
          .whereType<Map<String, dynamic>>()
          .map(CustomerModel.fromJson)
          .toList();

      return {
        'customers': customers,
        'pagination': responseData['pagination'] is Map
            ? Map<String, dynamic>.from(responseData['pagination'])
            : <String, dynamic>{},
      };
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    } catch (e) {
      throw Exception(_cleanException(e));
    }
  }

  // ============================================================
  // GET /api/customers/:id
  // ============================================================

  Future<CustomerModel> getCustomerById(int id) async {
    try {
      final response = await _api.get(
        '${ApiConstants.customers}/$id',
      );

      final responseData = response.data;

      if (responseData is! Map<String, dynamic>) {
        throw Exception('Invalid server response.');
      }

      final data = responseData['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception(
          responseData['message']?.toString() ??
              'Customer data not found.',
        );
      }

      return CustomerModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    } catch (e) {
      throw Exception(_cleanException(e));
    }
  }

  // ============================================================
  // POST /api/customers
  // ============================================================

  Future<CustomerModel> createCustomer(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _api.post(
        ApiConstants.customers,data:
        body,
      );

      final responseData = response.data;

      if (responseData is! Map<String, dynamic>) {
        throw Exception('Invalid server response.');
      }

      final data = responseData['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception(
          responseData['message']?.toString() ??
              'Customer creation failed.',
        );
      }

      return CustomerModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    } catch (e) {
      throw Exception(_cleanException(e));
    }
  }

  // ============================================================
  // PUT /api/customers/:id
  // ============================================================

  Future<CustomerModel> updateCustomer(
    int id,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _api.put(
        '${ApiConstants.customers}/$id',data:
        body,
      );

      final responseData = response.data;

      if (responseData is! Map<String, dynamic>) {
        throw Exception('Invalid server response.');
      }

      final data = responseData['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception(
          responseData['message']?.toString() ??
              'Customer update failed.',
        );
      }

      return CustomerModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    } catch (e) {
      throw Exception(_cleanException(e));
    }
  }

  // ============================================================
  // PATCH /api/customers/:id/status
  // ============================================================

  Future<void> changeStatus(
    int id,
    String status,
  ) async {
    try {
      await _api.patch(
        '${ApiConstants.customers}/$id/status',data:
        {
          'status': status,
        },
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    } catch (e) {
      throw Exception(_cleanException(e));
    }
  }

  // ============================================================
  // DELETE /api/customers/:id
  // ============================================================

  Future<void> deleteCustomer(int id) async {
    try {
      await _api.delete(
        '${ApiConstants.customers}/$id',
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    } catch (e) {
      throw Exception(_cleanException(e));
    }
  }

  // ============================================================
  // ERROR HANDLER
  // ============================================================

  String _extractError(DioException e) {
    final responseData = e.response?.data;

    // Backend:
    // {
    //   "success": false,
    //   "message": "..."
    // }

    if (responseData is Map) {
      final message = responseData['message'];

      if (message != null &&
          message.toString().trim().isNotEmpty) {
        return message.toString();
      }

      // Express validation errors if returned as errors array
      final errors = responseData['errors'];

      if (errors is List && errors.isNotEmpty) {
        final firstError = errors.first;

        if (firstError is Map &&
            firstError['msg'] != null) {
          return firstError['msg'].toString();
        }

        return firstError.toString();
      }
    }

    // HTTP status based messages
    switch (e.response?.statusCode) {
      case 400:
        return 'Invalid request. Please check the entered details.';

      case 401:
        return 'Session expired. Please login again.';

      case 403:
        return 'You do not have permission to perform this action.';

      case 404:
        return 'Customer not found.';

      case 409:
        return 'Customer already exists.';

      case 422:
        return 'Please check the entered details.';

      case 500:
        return 'Server error. Please try again later.';
    }

    // Dio connection errors
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Please check your connection.';

      case DioExceptionType.connectionError:
        return 'Could not reach the server. Please check your connection.';

      case DioExceptionType.badCertificate:
        return 'Secure connection failed.';

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      default:
        return 'Something went wrong. Please try again.';
    }
  }

  String _cleanException(Object e) {
    final message = e.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }
}