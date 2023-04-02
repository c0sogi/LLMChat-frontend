import 'package:hive/hive.dart';

class AuthService {
  static const String _boxName = 'authBox';
  static const String _jwtKey = 'jwtToken';

  Future<void> saveToken(String token) async {
    final box = await Hive.openBox<String>(_boxName);
    box.put(_jwtKey, token);
  }

  Future<String?> getToken() async {
    final box = await Hive.openBox<String>(_boxName);
    return box.get(_jwtKey);
  }

  Future<void> deleteToken() async {
    final box = await Hive.openBox<String>(_boxName);
    box.delete(_jwtKey);
  }
}
