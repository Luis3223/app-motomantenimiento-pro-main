abstract class RemoteNotificationRepository {
  Future<void> linkAccount({required String email, required String password});

  Future<bool> get hasSession;

  Future<void> saveDevice({String? fcmToken, DateTime? nextOilDue});

  Future<void> sendAdminAlert({required String title, required String body});

  Future<void> signOut();
}
