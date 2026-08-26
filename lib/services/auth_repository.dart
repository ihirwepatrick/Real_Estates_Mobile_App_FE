import 'package:dio/dio.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  Future<({AppUser user, String accessToken})> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.dio.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );
    final user = AppUser.fromJson(res.data['user'] as Map<String, dynamic>);
    final session = res.data['session'] as Map<String, dynamic>;
    final token = session['accessToken'] as String;
    await _api.saveSession(
      accessToken: token,
      refreshToken: session['refreshToken'] as String?,
    );
    return (user: user, accessToken: token);
  }

  Future<({AppUser? user, String? accessToken, String? message})> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final res = await _api.dio.post(
      '/api/auth/register',
      data: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'phone': phone,
      },
    );

    final userJson = res.data['user'] as Map<String, dynamic>?;
    final session = res.data['session'] as Map<String, dynamic>?;
    if (userJson == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'Registration failed',
      );
    }
    final user = AppUser.fromJson(userJson);
    if (session != null && session['accessToken'] != null) {
      final token = session['accessToken'] as String;
      await _api.saveSession(
        accessToken: token,
        refreshToken: session['refreshToken'] as String?,
      );
      return (user: user, accessToken: token, message: null);
    }
    return (
      user: user,
      accessToken: null,
      message: res.data['message'] as String? ??
          'Account created. Please log in.',
    );
  }

  Future<AppUser?> me() async {
    if (!await _api.hasToken) return null;
    try {
      final res = await _api.dio.get('/api/auth/me');
      return AppUser.fromJson(res.data['user'] as Map<String, dynamic>);
    } on DioException {
      await _api.clearSession();
      return null;
    }
  }

  Future<void> logout() => _api.clearSession();
}
