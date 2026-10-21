import 'package:sqflite/sqflite.dart';

import 'pending_change.dart';
import 'remote_record.dart';
import 'sync_store.dart';

/// Cola `pending_changes` y aplicación de filas remotas sobre SQLite.
class SqliteSyncStore implements SyncStore {
  SqliteSyncStore(this.db, {this.onChanged});

  final Database db;
  final void Function()? onChanged;

  @override
  Future<void> enqueue(PendingChange change) async {
    await db.delete(
      'pending_changes',
      where: 'entity = ? AND sync_id = ?',
      whereArgs: [change.entity, change.syncId],
    );
    await db.insert('pending_changes', {
      'sync_id': change.syncId,
      'entity': change.entity,
      'operation': change.operation,
      'payload': encodePayload(change.payload),
      'base_updated_at': change.baseUpdatedAt?.toUtc().toIso8601String(),
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<List<PendingChange>> pending() async {
    final rows = await db.query('pending_changes', orderBy: 'id ASC');
    return rows.map(_changeFromRow).toList();
  }

  @override
  Future<void> removePending(PendingChange change) async {
    await db.delete(
      'pending_changes',
      where: 'entity = ? AND sync_id = ?',
      whereArgs: [change.entity, change.syncId],
    );
  }

  @override
  Future<void> applyRemote(RemoteRecord record) async {
    if (record.entity == entityProfile) {
      await _writeProfile(record);
    } else {
      await _writeService(record);
    }
    onChanged?.call();
  }

  @override
  Future<void> markSynced(PendingChange change, RemoteRecord saved) async {
    await applyRemote(saved);
    await removePending(change);
  }

  @override
  Future<void> replaceFromRemote({
    required List<RemoteRecord> profiles,
    required List<RemoteRecord> services,
  }) async {
    if (profiles.isEmpty) return;
    final queued = await pending();
    final pendingProfiles = queued
        .where((change) => change.entity == entityProfile)
        .map((change) => change.syncId)
        .toSet();
    final pendingServices = queued
        .where((change) => change.entity == entityService)
        .map((change) => change.syncId)
        .toSet();

    for (final record in profiles) {
      if (pendingProfiles.contains(record.id)) continue;
      await _writeProfile(record);
    }
    for (final record in services) {
      if (pendingServices.contains(record.id)) continue;
      await _writeService(record);
    }

    final profileIds = profiles.map((record) => record.id).toSet()
      ..addAll(pendingProfiles);
    final serviceIds = services.map((record) => record.id).toSet()
      ..addAll(pendingServices);

    final localUsers = await db.query('users', columns: ['id']);
    for (final row in localUsers) {
      final id = row['id']! as String;
      if (profileIds.contains(id)) continue;
      await db.delete('users', where: 'id = ?', whereArgs: [id]);
    }
    final localServices = await db.query('services', columns: ['sync_id']);
    for (final row in localServices) {
      final id = row['sync_id'] as String?;
      if (id == null || serviceIds.contains(id)) continue;
      await db.delete('services', where: 'sync_id = ?', whereArgs: [id]);
    }
    onChanged?.call();
  }

  Future<void> _writeProfile(RemoteRecord record) async {
    final existing = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [record.id],
      limit: 1,
    );
    final previous = existing.isEmpty ? null : existing.first;
    final isAdmin = record.fields['is_admin'] == true;
    final values = <String, Object?>{
      'email': _text(record.fields['email'], previous?['email']),
      'password': previous?['password'] ?? '',
      'name': _text(record.fields['name'], previous?['name']),
      'bikeModel': _text(record.fields['bike_model'], previous?['bikeModel']),
      'bikePlate': _text(record.fields['bike_plate'], previous?['bikePlate']),
      'bikeYear': _text(record.fields['bike_year'], previous?['bikeYear']),
      'bikeVin': _text(record.fields['bike_vin'], previous?['bikeVin']),
      'profileImage': _text(
        record.fields['profile_image'],
        previous?['profileImage'],
      ),
      'isAdmin': isAdmin ? 1 : 0,
      'remote_updated_at': record.updatedAt.toUtc().toIso8601String(),
    };
    if (previous == null) {
      await db.insert('users', {'id': record.id, ...values});
    } else {
      await db.update('users', values, where: 'id = ?', whereArgs: [record.id]);
    }
  }

  Future<void> _writeService(RemoteRecord record) async {
    final values = <String, Object?>{
      'userId': record.fields['user_id'],
      'type': record.fields['type'],
      'date': record.fields['service_date'],
      'mileage': record.fields['mileage'],
      'notes': record.fields['notes'] ?? '',
      'category': record.fields['category'],
      'sync_id': record.id,
      'remote_updated_at': record.updatedAt.toUtc().toIso8601String(),
      'deleted_at': record.deletedAt?.toUtc().toIso8601String(),
    };
    final existing = await db.query(
      'services',
      columns: ['id'],
      where: 'sync_id = ?',
      whereArgs: [record.id],
      limit: 1,
    );
    if (existing.isEmpty) {
      await db.insert('services', values);
    } else {
      await db.update(
        'services',
        values,
        where: 'sync_id = ?',
        whereArgs: [record.id],
      );
    }
  }
}

PendingChange _changeFromRow(Map<String, Object?> row) {
  return PendingChange(
    entity: row['entity']! as String,
    syncId: row['sync_id']! as String,
    operation: row['operation']! as String,
    payload: decodePayload(row['payload']! as String),
    baseUpdatedAt: parseServerTime(row['base_updated_at'] as String?),
  );
}

String _text(Object? incoming, Object? previous) {
  if (incoming is String) return incoming;
  if (previous is String) return previous;
  return '';
}
