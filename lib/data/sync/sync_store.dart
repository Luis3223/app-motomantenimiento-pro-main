import 'pending_change.dart';
import 'remote_record.dart';

/// Cola y caché que el motor de sincronización actualiza.
abstract class SyncStore {
  Future<void> enqueue(PendingChange change);

  Future<List<PendingChange>> pending();

  Future<void> removePending(PendingChange change);

  Future<void> applyRemote(RemoteRecord record);

  Future<void> markSynced(PendingChange change, RemoteRecord saved);

  Future<void> replaceFromRemote({
    required List<RemoteRecord> profiles,
    required List<RemoteRecord> services,
  });
}
