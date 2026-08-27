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
    try {
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
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['requiresEmailVerification'] == true) {
        throw EmailVerificationRequiredException(
          email: data['email']?.toString() ?? email,
          message: data['error']?.toString() ??
              'Please verify your email with the code we sent.',
        );
      }
      rethrow;
    }
  }

  Future<
      ({
        AppUser? user,
        String? accessToken,
        bool requiresEmailVerification,
        String? email,
        String? message,
      })> register({
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

    final requires =
        res.data['requiresEmailVerification'] == true ||
        res.data['session'] == null;
    final userJson = res.data['user'] as Map<String, dynamic>?;
    final session = res.data['session'] as Map<String, dynamic>?;

    if (requires) {
      return (
        user: userJson != null ? AppUser.fromJson(userJson) : null,
        accessToken: null,
        requiresEmailVerification: true,
        email: (res.data['email'] as String?) ?? email,
        message: res.data['message'] as String?,
      );
    }

    if (userJson == null || session == null || session['accessToken'] == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'Registration failed',
      );
    }

    final user = AppUser.fromJson(userJson);
    final token = session['accessToken'] as String;
    await _api.saveSession(
      accessToken: token,
      refreshToken: session['refreshToken'] as String?,
    );
    return (
      user: user,
      accessToken: token,
      requiresEmailVerification: false,
      email: email,
      message: null,
    );
  }

  Future<({AppUser user, String accessToken})> verifyOtp({
    required String email,
    required String token,
    required String type,
  }) async {
    final res = await _api.dio.post(
      '/api/auth/verify-otp',
      data: {'email': email, 'token': token, 'type': type},
    );
    final user = AppUser.fromJson(res.data['user'] as Map<String, dynamic>);
    final session = res.data['session'] as Map<String, dynamic>;
    final accessToken = session['accessToken'] as String;
    await _api.saveSession(
      accessToken: accessToken,
      refreshToken: session['refreshToken'] as String?,
    );
    return (user: user, accessToken: accessToken);
  }

  Future<String> resendOtp({
    required String email,
    String type = 'signup',
  }) async {
    final res = await _api.dio.post(
      '/api/auth/resend-otp',
      data: {'email': email, 'type': type},
    );
    return res.data['message'] as String? ?? 'Code sent';
  }

  Future<String> forgotPassword({required String email}) async {
    final res = await _api.dio.post(
      '/api/auth/forgot-password',
      data: {'email': email},
    );
    return res.data['message'] as String? ??
        'If an account exists, a reset code was sent.';
  }

  Future<({AppUser user, String accessToken})> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    final res = await _api.dio.post(
      '/api/auth/reset-password',
      data: {'email': email, 'token': token, 'password': password},
    );
    final user = AppUser.fromJson(res.data['user'] as Map<String, dynamic>);
    final session = res.data['session'] as Map<String, dynamic>;
    final accessToken = session['accessToken'] as String;
    await _api.saveSession(
      accessToken: accessToken,
      refreshToken: session['refreshToken'] as String?,
    );
    return (user: user, accessToken: accessToken);
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

class EmailVerificationRequiredException implements Exception {
  EmailVerificationRequiredException({
    required this.email,
    required this.message,
  });

  final String email;
  final String message;

  @override
  String toString() => message;
}
