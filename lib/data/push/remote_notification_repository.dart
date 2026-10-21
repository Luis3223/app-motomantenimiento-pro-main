abstract class RemoteNotificationRepository {
  Future<bool> get hasSession;

  Future<void> saveDevice({String? fcmToken, DateTime? nextOilDue});

  Future<void> sendAdminAlert({required String title, required String body});

  Future<void> signOut();
}
