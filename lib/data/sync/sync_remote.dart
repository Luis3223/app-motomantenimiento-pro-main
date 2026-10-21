import 'pending_change.dart';
import 'remote_record.dart';

/// Lectura y escritura en Postgres. Lanza si no hay red.
abstract class SyncRemote {
  Future<RemoteRecord?> fetch(String entity, String id);

  Future<RemoteRecord> push(PendingChange change);

  Future<List<RemoteRecord>> pullProfiles();

  Future<List<RemoteRecord>> pullServices();
}
