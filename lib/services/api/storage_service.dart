import 'package:hive/hive.dart';

class StorageService {
  static const String boxName = "appBox";

  static const String tokenKey = "token";
  static const String adminIdKey = "adminId";
  static const String usernameKey = "username";

  // ============================================================
  // OPEN BOX
  // ============================================================

  static Future<Box> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }

    return await Hive.openBox(boxName);
  }

  // ============================================================
  // SAVE LOGIN SESSION
  // ============================================================

  static Future<void> saveSession({
    required String token,
    int? adminId,
    String? username,
  }) async {
    final box = await _getBox();

    await box.put(tokenKey, token);

    if (adminId != null) {
      await box.put(adminIdKey, adminId);
    }

    if (username != null && username.isNotEmpty) {
      await box.put(usernameKey, username);
    }
  }

  // ============================================================
  // SAVE TOKEN
  // ============================================================

  static Future<void> saveToken(String token) async {
    final box = await _getBox();

    await box.put(tokenKey, token);
  }

  // ============================================================
  // GET TOKEN
  // ============================================================

  static Future<String?> getToken() async {
    final box = await _getBox();

    final token = box.get(tokenKey);

    if (token == null) {
      return null;
    }

    return token.toString();
  }

  // ============================================================
  // GET ADMIN ID
  // ============================================================

  static Future<int?> getAdminId() async {
    final box = await _getBox();

    final value = box.get(adminIdKey);

    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  // ============================================================
  // GET USERNAME
  // ============================================================

  static Future<String?> getUsername() async {
    final box = await _getBox();

    final value = box.get(usernameKey);

    return value?.toString();
  }

  // ============================================================
  // CHECK LOGIN
  // ============================================================

  static Future<bool> isLoggedIn() async {
    final token = await getToken();

    return token != null && token.isNotEmpty;
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    final box = await _getBox();

    await box.clear();
  }
}