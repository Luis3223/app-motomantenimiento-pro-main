import 'package:supabase_flutter/supabase_flutter.dart';

import 'pending_change.dart';
import 'remote_record.dart';
import 'sync_remote.dart';

class SupabaseSyncRemote implements SyncRemote {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<RemoteRecord?> fetch(String entity, String id) async {
    final table = entity == entityProfile ? 'profiles' : 'services';
    final row = await _client.from(table).select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return entity == entityProfile ? _profile(row) : _service(row);
  }

  @override
  Future<RemoteRecord> push(PendingChange change) async {
    if (change.entity == entityProfile) {
      final row = await _client
          .from('profiles')
          .upsert({'id': change.syncId, ...change.payload})
          .select()
          .single();
      return _profile(row);
    }
    if (change.operation == opDelete) {
      final row = await _client
          .from('services')
          .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', change.syncId)
          .select()
          .maybeSingle();
      if (row == null) {
        final now = DateTime.now().toUtc();
        return RemoteRecord(
          entity: entityService,
          id: change.syncId,
          updatedAt: now,
          deletedAt: now,
          fields: change.payload,
        );
      }
      return _service(row);
    }
    final row = await _client
        .from('services')
        .upsert({'id': change.syncId, ...change.payload})
        .select()
        .single();
    return _service(row);
  }

  @override
  Future<List<RemoteRecord>> pullProfiles() async {
    final rows = await _client.from('profiles').select();
    return rows.map(_profile).toList();
  }

  @override
  Future<List<RemoteRecord>> pullServices() async {
    final rows = await _client.from('services').select();
    return rows.map(_service).toList();
  }
}

RemoteRecord _profile(Map<String, dynamic> row) {
  return RemoteRecord(
    entity: entityProfile,
    id: row['id'] as String,
    updatedAt: DateTime.parse(row['updated_at'] as String).toUtc(),
    fields: {
      'email': row['email'],
      'name': row['name'],
      'bike_model': row['bike_model'],
      'bike_plate': row['bike_plate'],
      'bike_year': row['bike_year'],
      'bike_vin': row['bike_vin'],
      'profile_image': row['profile_image'],
      'is_admin': row['is_admin'] == true,
    },
  );
}

RemoteRecord _service(Map<String, dynamic> row) {
  final deleted = row['deleted_at'];
  return RemoteRecord(
    entity: entityService,
    id: row['id'] as String,
    updatedAt: DateTime.parse(row['updated_at'] as String).toUtc(),
    deletedAt: deleted == null
        ? null
        : DateTime.parse(deleted as String).toUtc(),
    fields: {
      'user_id': row['user_id'],
      'type': row['type'],
      'service_date': row['service_date'],
      'mileage': row['mileage'],
      'notes': row['notes'],
      'category': row['category'],
    },
  );
}
