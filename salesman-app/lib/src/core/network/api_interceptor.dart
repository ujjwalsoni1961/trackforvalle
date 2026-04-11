// ignore_for_file: non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/injector/injector.dart';
import 'package:track/src/core/local/user_local_data_source.dart';
import 'package:track/src/core/ui/routes/routes.dart';
import 'package:track/main.dart';
import 'dart:developer';

class APIInterceptor extends Interceptor {
  static String BASE_URL = "https://track-seven-omega.vercel.app/api";

  static bool isStaging = false;
  
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final res = await sl<UserLocalDataSource>().getUserData();
    res.fold((failure) => null, (userData) {
      options.headers['Authorization'] = 'Bearer ${userData.accessToken}';
    });
    options.validateStatus = (status) {
      return status! < 600;
    };
    options.headers['Content-Type'] = 'application/json';
    options.baseUrl = isStaging
        ? "https://salesman-app.onrender.com/api"
        : BASE_URL;
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check for token-related errors
    final isTokenError = err.response?.statusCode == 401 || 
                        _isTokenNotProvidedError(err);
    
    if (isTokenError) {
      log('Token error detected, attempting refresh...');
      
      final refreshResult = await _refreshToken();
      if (refreshResult) {
        // Retry the original request with new token
        try {
          final clonedRequest = await _cloneRequest(err.requestOptions);
          final response = await Dio().fetch(clonedRequest);
          return handler.resolve(response);
        } catch (retryError) {
          log('Retry request failed: $retryError');
          // If retry fails, attempt one more time
          final secondRefreshResult = await _refreshToken();
          if (secondRefreshResult) {
            try {
              final secondClonedRequest = await _cloneRequest(err.requestOptions);
              final response = await Dio().fetch(secondClonedRequest);
              return handler.resolve(response);
            } catch (secondRetryError) {
              log('Second retry failed, logging out: $secondRetryError');
              await _logoutUser();
            }
          } else {
            log('Second token refresh failed, logging out');
            await _logoutUser();
          }
        }
      } else {
        log('Token refresh failed, logging out');
        await _logoutUser();
      }
    }
    
    // Handle session timeout - extend session for active users
    if (err.response?.statusCode == 403) {
      await _extendSession();
    }
    
    super.onError(err, handler);
  }
  
  bool _isTokenNotProvidedError(DioException err) {
    final responseData = err.response?.data;
    if (responseData is Map<String, dynamic>) {
      final error = responseData['error'];
      if (error is Map<String, dynamic>) {
        final message = error['message']?.toString().toLowerCase();
        return message?.contains('token not provided') == true ||
               message?.contains('token missing') == true ||
               message?.contains('authorization required') == true;
      }
      // Also check for success: false with token-related messages
      if (responseData['success'] == false) {
        final errorMessage = responseData['message']?.toString().toLowerCase();
        return errorMessage?.contains('token') == true;
      }
    }
    return false;
  }
  
  Future<void> _logoutUser() async {
    try {
      // Remove user data from local storage
      await sl<UserLocalDataSource>().removeUserData();
      
      // Navigate to login screen
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        context.go(Routes.firstPage);
      }
      
      log('User logged out due to authentication failure');
    } catch (e) {
      log('Error during logout: $e');
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final userDataRes = await sl<UserLocalDataSource>().getUserData();
      return userDataRes.fold(
        (failure) => false,
        (userData) async {
          if (userData.refreshToken.isEmpty) {
            return false;
          }

          final dio = Dio();
          dio.options.baseUrl = isStaging
              ? "https://salesman-app.onrender.com/api"
              : BASE_URL;

          final response = await dio.post(
            '/auth/refresh',
            data: {'refresh_token': userData.refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['data']['access_token'];
            final newRefreshToken = response.data['data']['refresh_token'];
            
            // Update stored tokens
            await sl<UserLocalDataSource>().updateUserData(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );
            
            log('Token refreshed successfully');
            return true;
          }
          return false;
        },
      );
    } catch (e) {
      log('Token refresh error: $e');
      return false;
    }
  }

  Future<void> _extendSession() async {
    try {
      final userDataRes = await sl<UserLocalDataSource>().getUserData();
      userDataRes.fold(
        (failure) => null,
        (userData) async {
          final dio = Dio();
          dio.options.baseUrl = isStaging
              ? "https://salesman-app.onrender.com/api"
              : BASE_URL;
          dio.options.headers['Authorization'] = 'Bearer ${userData.accessToken}';

          await dio.put('/auth/extend-session');
          log('Session extended successfully');
        },
      );
    } catch (e) {
      log('Session extension error: $e');
    }
  }

  Future<RequestOptions> _cloneRequest(RequestOptions options) async {
    final userDataRes = await sl<UserLocalDataSource>().getUserData();
    userDataRes.fold(
      (failure) => null,
      (userData) {
        options.headers['Authorization'] = 'Bearer ${userData.accessToken}';
      },
    );
    return options;
  }
}
