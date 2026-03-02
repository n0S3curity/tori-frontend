import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  final FlutterSecureStorage _storage;

  static const String _jwtKey = 'jwt_token';
  static const String _fcmKey = 'fcm_token';
  static const String _userKey = 'cached_user';

  Future<void> saveJwt(String token) => _storage.write(key: _jwtKey, value: token);
  Future<String?> getJwt() => _storage.read(key: _jwtKey);
  Future<void> deleteJwt() => _storage.delete(key: _jwtKey);

  Future<void> saveFcmToken(String token) => _storage.write(key: _fcmKey, value: token);
  Future<String?> getFcmToken() => _storage.read(key: _fcmKey);

  Future<void> saveUser(String userJson) => _storage.write(key: _userKey, value: userJson);
  Future<String?> getUser() => _storage.read(key: _userKey);

  Future<void> clearAll() => _storage.deleteAll();
}
