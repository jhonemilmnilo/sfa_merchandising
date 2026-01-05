// lib/data/auth/auth_session.dart
import "../../models/app_user.dart";

class AuthSession {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  AppUser? _user;

  AppUser? get user => _user;

  void setUser(AppUser user) {
    _user = user;
  }
  void clear() {
    _user = null;
  }

  bool get isLoggedIn => _user != null;
}
