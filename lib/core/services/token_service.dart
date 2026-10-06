import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';

  // ------------------------------------------------------------
  // Current application session token
  // ------------------------------------------------------------

  static String? _sessionToken;

  // ------------------------------------------------------------
  // Set token for the current session
  //
  // The token is ALWAYS kept in memory while the user is logged in.
  //
  // If rememberMe is true, it is also stored securely so that
  // the session can be restored after the application is closed.
  // ------------------------------------------------------------

  Future<void> setToken(
      String token, {
        required bool rememberMe,
      }) async {
    _sessionToken = token;

    if (rememberMe) {
      await _storage.write(
        key: _tokenKey,
        value: token,
      );
    } else {
      await _storage.delete(
        key: _tokenKey,
      );
    }
  }

  // ------------------------------------------------------------
  // Get token
  //
  // First return the current session token.
  //
  // If there is no active session token, check secure storage.
  // This is what allows Remember Me to restore a session after
  // restarting the application.
  // ------------------------------------------------------------

  Future<String?> getToken() async {
    if (_sessionToken != null &&
        _sessionToken!.isNotEmpty) {
      return _sessionToken;
    }

    return await _storage.read(
      key: _tokenKey,
    );
  }

  // ------------------------------------------------------------
  // Save token directly
  //
  // Kept for compatibility with existing code.
  // ------------------------------------------------------------

  Future<void> saveToken(String token) async {
    _sessionToken = token;

    await _storage.write(
      key: _tokenKey,
      value: token,
    );
  }

  // ------------------------------------------------------------
  // Delete token
  //
  // Used when logging out or when a stored session is invalid.
  // ------------------------------------------------------------

  Future<void> deleteToken() async {
    _sessionToken = null;

    await _storage.delete(
      key: _tokenKey,
    );
  }
}
