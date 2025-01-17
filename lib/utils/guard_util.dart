import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class Vania {
  static const _secureStorage = FlutterSecureStorage();

  static Future<bool> isLoggedIn() async {
    String? accessToken = await _getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  static Future<String?> _getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  // Menambahkan method public untuk getAccessToken
  static Future<String?> getAccessToken() async {
    return await _getAccessToken();
  }

  static Future<void> saveTokens(
      String accessToken, String refreshToken) async {
    await _secureStorage.write(key: 'access_token', value: accessToken);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  static Future<void> deleteTokens() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await _getAccessToken();
      if (token == null) return null;

      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = json.decode(decoded);

      return data['pld'] as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
