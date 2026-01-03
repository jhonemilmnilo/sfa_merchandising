import "../../models/app_user.dart";
import "../../services/user_api.dart";
import "../local/users_local_dao.dart";

class AuthRepository {
  final UserApi _api;
  final UsersLocalDao _local;

   AuthRepository({
    UserApi api = const UserApi(),
    UsersLocalDao? local,
  })  : _api = api,
        _local = local ?? UsersLocalDao.instance;

  /// Online-first then offline fallback:
  /// 1) Try online auth (fetch by email then compare password)
  ///    - If success: cache user locally, return user
  /// 2) If online fails (network/server): try offline auth from SQLite
  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    final e = email.trim();
    final p = password.trim();

    // ---- 1) ONLINE FIRST ----
    try {
      final onlineUser = await _api.authenticateOnline(email: e, password: p);
      if (onlineUser != null) {
        await _local.upsertUser(onlineUser); // cache for offline use
        return onlineUser;
      }
      // Online reached server but credentials wrong -> do not fallback silently.
      // (If you want to fallback even on wrong creds, tell me.)
      return null;
    } catch (_) {
      // ---- 2) OFFLINE FALLBACK ----
      return _local.authenticateOffline(email: e, password: p);
    }
  }
}
