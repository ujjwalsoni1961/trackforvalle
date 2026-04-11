import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:track/src/core/network/api_interceptor.dart';

class API {
  late final Dio _dio;
  API() {
    _dio = Dio();
    dio.options.validateStatus = (status) {
      // Allow all status codes
      return true;
    };

    _dio.interceptors.add(APIInterceptor());
    _dio.interceptors.add(
      PrettyDioLogger(requestBody: true, responseBody: true),
    );
  }

  Dio get dio => _dio;
}
