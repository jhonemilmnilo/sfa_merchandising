import "package:flutter/foundation.dart";
import "package:sfa_merchandising/models/app_user.dart";

class AuthSession {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  final ValueNotifier<AppUser?> currentUser = ValueNotifier<AppUser?>(null);

  AppUser? get user => currentUser.value;
  bool get isLoggedIn => currentUser.value != null;

  void setUser(AppUser user) {
    currentUser.value = user;
  }

  void clear() {
    currentUser.value = null;
  }
}
