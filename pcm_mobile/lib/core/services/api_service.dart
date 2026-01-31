import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/api_config.dart';

/// API Service - Quản lý HTTP requests với Dio
/// Tự động thêm JWT token vào headers

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late Box _cacheBox;
  bool _isCacheInit = false;
  
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Add Interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Log URL
        debugPrint('REQUEST: ${options.method} ${options.uri}');
        
        // Tự động thêm JWT token vào header
        final token = await _storage.read(key: 'jwt_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Xử lý lỗi 401 - Token hết hạn
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'jwt_token');
          // TODO: Navigate to login screen
        }
        return handler.next(error);
      },
    ));
  }
  
  Dio get dio => _dio;
  
  // Generic GET request với Cache
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, bool useCache = true}) async {
    if (useCache) {
      if (!_isCacheInit) {
        _cacheBox = await Hive.openBox('api_cache');
        _isCacheInit = true;
      }
      
      final cacheKey = path + (queryParameters?.toString() ?? "");
      final cachedData = _cacheBox.get(cacheKey);
      
      if (cachedData != null) {
        debugPrint('CACHE HIT: $path');
        return Response(
          data: cachedData,
          statusCode: 200,
          requestOptions: RequestOptions(path: path),
        );
      }
    }

    final response = await _dio.get(path, queryParameters: queryParameters);
    
    if (useCache && response.statusCode == 200) {
      final cacheKey = path + (queryParameters?.toString() ?? "");
      _cacheBox.put(cacheKey, response.data);
    }
    
    return response;
  }
  
  // Generic POST request
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }
  
  // Generic PUT request
  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }
  
  // Generic DELETE request
  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.delete(path, queryParameters: queryParameters);
  }
  
  // Upload file
  Future<Response> uploadFile(String path, String filePath, String fieldName) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
    });
    return await _dio.post(path, data: formData);
  }
  
  // Token management
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }
  
  Future<void> clearToken() async {
    await _storage.delete(key: 'jwt_token');
  }
  
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
