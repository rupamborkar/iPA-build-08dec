import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  // Create a secure storage instance
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Keys for storing tokens
  static const _tokenKey = 'jwt_token';

  /// Save the JWT token
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw Exception("Error saving token: $e");
    }
  }

  /// Retrieve the JWT token
  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      throw Exception("Error retrieving token: $e");
    }
  }

  /// Delete the JWT token
  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      throw Exception("Error deleting token: $e");
    }
  }

  /// Check if a token exists
  static Future<bool> hasToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      return token != null;
    } catch (e) {
      throw Exception("Error checking token: $e");
    }
  }
}
