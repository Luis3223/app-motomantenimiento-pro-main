import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config.dart';
import 'push_message.dart';
import 'remote_notification_repository.dart';

class SupabaseRemoteNotifications implements RemoteNotificationRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<void> init() {
    return Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    );
  }

  @override
  Future<bool> get hasSession async => _client.auth.currentSession != null;

  @override
  Future<void> saveDevice({String? fcmToken, DateTime? nextOilDue}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    final row = <String, Object?>{
      'id': userId,
      'next_oil_due': _dateOrNull(nextOilDue),
    };
    if (fcmToken != null && fcmToken.isNotEmpty) {
      row['fcm_token'] = fcmToken;
    }
    await _client.from('profiles').upsert(row);
  }

  @override
  Future<void> sendAdminAlert({
    required String title,
    required String body,
  }) async {
    final data = navigationPayload(pushRouteHistory);
    await _client.from('notifications').insert({
      'title': title,
      'body': body,
      'route': data['route'],
    });
  }

  @override
  Future<void> signOut() async {
    if (_client.auth.currentSession == null) return;
    await _client.auth.signOut();
  }
}

String? _dateOrNull(DateTime? date) {
  if (date == null) return null;
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-$month-$day';
}
