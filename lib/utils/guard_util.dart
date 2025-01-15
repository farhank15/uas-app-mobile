import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Vania {
  static final _secureStorage = const FlutterSecureStorage();

  /// Periksa apakah pengguna sudah login
  static Future<bool> isLoggedIn() async {
    String? jwtToken = await _getJwtToken();
    return jwtToken != null && jwtToken.isNotEmpty;
  }

  /// Ambil token JWT dari SecureStorage
  static Future<String?> _getJwtToken() async {
    return await _secureStorage.read(key: 'jwtToken');
  }

  /// Simpan token JWT ke SecureStorage
  static Future<void> saveJwtToken(String token) async {
    await _secureStorage.write(key: 'jwtToken', value: token);
  }

  /// Hapus token JWT dari SecureStorage
  static Future<void> deleteJwtToken() async {
    await _secureStorage.delete(key: 'jwtToken');
  }
}
