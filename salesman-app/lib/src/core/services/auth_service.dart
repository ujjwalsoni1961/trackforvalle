import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:track/src/core/local/user_local_data_source.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';

/// Service class for handling JWT authentication state and validation
/// Provides methods to check authentication status, token expiry, and user data
class AuthService {
  final UserLocalDataSource _localDataSource;

  AuthService(this._localDataSource);

  /// Check if user is authenticated with valid token
  /// Returns true if user has a valid non-expired JWT token
  Future<bool> isAuthenticated() async {
    try {
      print('🔐 AuthService: Checking authentication status...');
      final result = await _localDataSource.getUserData();

      return result.fold(
        (failure) {
          print('🔐 AuthService: User NOT authenticated - ${failure.message}');
          log('AuthService: User not authenticated - ${failure.message}');
          return false;
        },
        (userData) {
          // Check if tokens exist
          if (userData.accessToken.isEmpty) {
            print('🔐 AuthService: No access token found');
            log('AuthService: No access token found');
            return false;
          }

          // Check if token is expired
          if (_isTokenExpired(userData.accessToken)) {
            print('🔐 AuthService: Access token expired');
            log('AuthService: Access token expired');
            return false;
          }

          print('🔐 AuthService: User IS authenticated ✅');
          log('AuthService: User is authenticated');
          return true;
        },
      );
    } catch (e) {
      print('🔐 AuthService: Error checking authentication - $e');
      log('AuthService: Error checking authentication - $e');
      return false;
    }
  }

  /// Get current user data if authenticated
  Future<Either<String, UserEntity>> getCurrentUser() async {
    try {
      final result = await _localDataSource.getUserData();

      return result.fold(
        (failure) => Left(failure.message),
        (userData) {
          if (_isTokenExpired(userData.accessToken)) {
            return const Left('Token expired');
          }
          return Right(userData);
        },
      );
    } catch (e) {
      log('AuthService: Error getting current user - $e');
      return Left(e.toString());
    }
  }

  /// Check if JWT token is expired
  /// Returns true if token is expired or invalid
  bool _isTokenExpired(String token) {
    try {
      // JWT structure: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        log('AuthService: Invalid token format');
        return true;
      }

      // Decode the payload (second part)
      final payload = parts[1];

      // Add padding if needed for base64 decoding
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      // Check expiration time (exp claim in seconds since epoch)
      if (payloadMap.containsKey('exp')) {
        final exp = payloadMap['exp'] as int;
        final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        final now = DateTime.now();

        // Add 30 second buffer for clock skew
        final isExpired = now.isAfter(expirationDate.subtract(const Duration(seconds: 30)));

        if (isExpired) {
          log('AuthService: Token expired at $expirationDate (now: $now)');
        } else {
          log('AuthService: Token valid until $expirationDate');
        }

        return isExpired;
      }

      // If no exp claim, consider token as non-expiring (valid)
      log('AuthService: Token has no expiration claim');
      return false;
    } catch (e) {
      log('AuthService: Error parsing token - $e');
      // If we can't parse the token, consider it expired/invalid
      return true;
    }
  }

  /// Get time until token expires
  /// Returns null if token is invalid or already expired
  Duration? getTokenTimeRemaining(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      if (payloadMap.containsKey('exp')) {
        final exp = payloadMap['exp'] as int;
        final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        final now = DateTime.now();

        if (now.isAfter(expirationDate)) {
          return null; // Already expired
        }

        return expirationDate.difference(now);
      }

      return null;
    } catch (e) {
      log('AuthService: Error getting token time remaining - $e');
      return null;
    }
  }

  /// Check if user needs to verify email
  Future<bool> needsEmailVerification() async {
    try {
      final result = await _localDataSource.getUserData();

      return result.fold(
        (failure) => false,
        (userData) => !userData.isEmailVerified,
      );
    } catch (e) {
      log('AuthService: Error checking email verification - $e');
      return false;
    }
  }

  /// Logout user by removing local data
  Future<void> logout() async {
    try {
      await _localDataSource.removeUserData();
      log('AuthService: User logged out successfully');
    } catch (e) {
      log('AuthService: Error during logout - $e');
    }
  }

  /// Check if refresh token exists and is valid
  Future<bool> hasValidRefreshToken() async {
    try {
      final result = await _localDataSource.getUserData();

      return result.fold(
        (failure) => false,
        (userData) {
          if (userData.refreshToken.isEmpty) {
            return false;
          }

          // Check if refresh token is expired
          if (_isTokenExpired(userData.refreshToken)) {
            log('AuthService: Refresh token expired');
            return false;
          }

          return true;
        },
      );
    } catch (e) {
      log('AuthService: Error checking refresh token - $e');
      return false;
    }
  }
}
