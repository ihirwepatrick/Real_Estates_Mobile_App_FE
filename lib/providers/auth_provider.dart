import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repo);

  final AuthRepository _repo;

  AppUser? _user;
  bool _loading = true;
  String? _error;
  String? _pendingEmail;
  bool _needsEmailVerification = false;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get loading => _loading;
  String? get error => _error;
  String? get pendingEmail => _pendingEmail;
  bool get needsEmailVerification => _needsEmailVerification;

  Future<void> bootstrap() async {
    _loading = true;
    notifyListeners();
    try {
      _user = await _repo.me();
    } catch (_) {
      _user = null;
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _error = null;
    _needsEmailVerification = false;
    notifyListeners();
    try {
      final result = await _repo.login(email: email, password: password);
      _user = result.user;
      _pendingEmail = null;
      notifyListeners();
      return true;
    } on EmailVerificationRequiredException catch (e) {
      _needsEmailVerification = true;
      _pendingEmail = e.email;
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = _extractError(e);
      notifyListeners();
      return false;
    }
  }

  /// Returns true if fully logged in. If OTP is required, sets pendingEmail
  /// and returns false with needsEmailVerification = true.
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    _error = null;
    _needsEmailVerification = false;
    notifyListeners();
    try {
      final result = await _repo.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      if (result.requiresEmailVerification) {
        _needsEmailVerification = true;
        _pendingEmail = result.email ?? email;
        _error = result.message;
        notifyListeners();
        return false;
      }
      if (result.accessToken != null && result.user != null) {
        _user = result.user;
        _pendingEmail = null;
        notifyListeners();
        return true;
      }
      _error = result.message ?? 'Registration failed';
      notifyListeners();
      return false;
    } catch (e) {
      _error = _extractError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp({
    required String email,
    required String token,
    String type = 'signup',
  }) async {
    _error = null;
    notifyListeners();
    try {
      final result = await _repo.verifyOtp(
        email: email,
        token: token,
        type: type,
      );
      _user = result.user;
      _needsEmailVerification = false;
      _pendingEmail = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendOtp({
    required String email,
    String type = 'signup',
  }) async {
    _error = null;
    notifyListeners();
    try {
      await _repo.resendOtp(email: email, type: type);
      return true;
    } catch (e) {
      _error = _extractError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _error = null;
    notifyListeners();
    try {
      await _repo.forgotPassword(email: email);
      _pendingEmail = email;
      return true;
    } catch (e) {
      _error = _extractError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    _error = null;
    notifyListeners();
    try {
      final result = await _repo.resetPassword(
        email: email,
        token: token,
        password: password,
      );
      _user = result.user;
      _pendingEmail = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setPendingEmail(String email) {
    _pendingEmail = email;
    notifyListeners();
  }

  String _extractError(Object e) {
    if (e is EmailVerificationRequiredException) return e.message;
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['error'] != null) {
        return data['error'].toString();
      }
      if (e.message != null && e.message!.isNotEmpty) {
        return e.message!;
      }
    }
    return e.toString().replaceFirst('Exception: ', '');
  }
}
