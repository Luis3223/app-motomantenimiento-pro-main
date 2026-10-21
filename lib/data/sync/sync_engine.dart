import 'sync_remote.dart';
import 'sync_store.dart';

/// Empuje y bajada de la cola. La pantalla solo pregunta si todo salió.
abstract class HistorySync {
  Future<void> pull();

  /// `false` si quedó algún cambio sin confirmar.
  Future<bool> flush();
}

class SyncEngine implements HistorySync {
  SyncEngine({required this.store, required this.remote});

  final SyncStore store;
  final SyncRemote remote;

  @override
  Future<void> pull() async {
    final profiles = await remote.pullProfiles();
    final services = await remote.pullServices();
    await store.replaceFromRemote(profiles: profiles, services: services);
  }

  @override
  Future<bool> flush() async {
    final batch = await store.pending();
    for (final change in batch) {
      try {
        final current = await remote.fetch(change.entity, change.syncId);
        final base = change.baseUpdatedAt;
        // Sin base, la fila aún no estaba en el servidor: se envía.
        // Con base, gana la copia cuyo updated_at de servidor es posterior.
        if (current != null &&
            base != null &&
            current.updatedAt.toUtc().isAfter(base.toUtc())) {
          await store.applyRemote(current);
          await store.removePending(change);
          continue;
        }
        final saved = await remote.push(change);
        await store.markSynced(change, saved);
      } catch (_) {
        return false;
      }
    }
    return true;
  }
}
