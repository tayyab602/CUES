import 'package:dio/dio.dart';
import 'auth_service.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "http://10.0.2.2:5000/api", // Android emulator localhost
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final AuthService _authService = AuthService();

  // Attach token to every request automatically
  Future<Options> _authHeaders() async {
    final token = await _authService.getToken();
    return Options(headers: {"Authorization": "Bearer $token"});
  }

  // GET
  Future<Response> get(String endpoint) async {
    return await _dio.get(endpoint);
  }

  // POST (protected)
  Future<Response> post(String endpoint, Map<String, dynamic> data) async {
    final options = await _authHeaders();
    return await _dio.post(endpoint, data: data, options: options);
  }

  // PUT (protected)
  Future<Response> put(String endpoint, Map<String, dynamic> data) async {
    final options = await _authHeaders();
    return await _dio.put(endpoint, data: data, options: options);
  }

  // DELETE (protected)
  Future<Response> delete(String endpoint) async {
    final options = await _authHeaders();
    return await _dio.delete(endpoint, options: options);
  }
}