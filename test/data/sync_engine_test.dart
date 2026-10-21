import 'package:flutter_test/flutter_test.dart';
import 'package:motomantenimiento_pro/data/sync/pending_change.dart';
import 'package:motomantenimiento_pro/data/sync/remote_record.dart';
import 'package:motomantenimiento_pro/data/sync/sync_engine.dart';
import 'package:motomantenimiento_pro/data/sync/sync_remote.dart';
import 'package:motomantenimiento_pro/data/sync/sync_store.dart';

void main() {
  late MemorySyncStore store;
  late _FakeRemote remote;
  late SyncEngine engine;

  setUp(() {
    store = MemorySyncStore();
    remote = _FakeRemote();
    engine = SyncEngine(store: store, remote: remote);
  });

  test(
    'un envío correcto vacía la cola y guarda la hora del servidor',
    () async {
      await store.enqueue(
        const PendingChange(
          entity: entityService,
          syncId: 's1',
          operation: opUpsert,
          payload: {'type': 'Frenos'},
        ),
      );

      final delivered = await engine.flush();

      expect(delivered, isTrue);
      expect(await store.pending(), isEmpty);
      expect(store.records['service/s1']?.updatedAt, _FakeRemote.serverTime);
      expect(remote.pushes, 1);
    },
  );

  test('si la red falla, el cambio sigue en la cola', () async {
    remote.offline = true;
    await store.enqueue(
      const PendingChange(
        entity: entityService,
        syncId: 's1',
        operation: opUpsert,
        payload: {'type': 'Frenos'},
      ),
    );

    final delivered = await engine.flush();

    expect(delivered, isFalse);
    expect(await store.pending(), hasLength(1));
    expect(remote.pushes, 0);
  });

  test('gana la fila del servidor cuando su updated_at es posterior', () async {
    final newer = DateTime.utc(2026, 10, 2);
    remote.rows['service/s1'] = RemoteRecord(
      entity: entityService,
      id: 's1',
      updatedAt: newer,
      fields: const {'type': 'Remoto'},
    );
    await store.enqueue(
      PendingChange(
        entity: entityService,
        syncId: 's1',
        operation: opUpsert,
        payload: const {'type': 'Local'},
        baseUpdatedAt: DateTime.utc(2026, 10, 1),
      ),
    );

    final delivered = await engine.flush();

    expect(delivered, isTrue);
    expect(remote.pushes, 0);
    expect(store.records['service/s1']?.fields['type'], 'Remoto');
    expect(await store.pending(), isEmpty);
  });

  test('un borrado suave se envía si nadie escribió después', () async {
    final base = DateTime.utc(2026, 10, 1);
    remote.rows['service/s1'] = RemoteRecord(
      entity: entityService,
      id: 's1',
      updatedAt: base,
      fields: const {'type': 'Frenos'},
    );
    await store.enqueue(
      PendingChange(
        entity: entityService,
        syncId: 's1',
        operation: opDelete,
        payload: const {'type': 'Frenos'},
        baseUpdatedAt: base,
      ),
    );

    final delivered = await engine.flush();

    expect(delivered, isTrue);
    expect(remote.pushes, 1);
    expect(store.records['service/s1']?.deletedAt, isNotNull);
    expect(await store.pending(), isEmpty);
  });

  test(
    'la primera subida se envía aunque el servidor ya tenga fecha',
    () async {
      remote.rows['profile/u1'] = RemoteRecord(
        entity: entityProfile,
        id: 'u1',
        updatedAt: DateTime.utc(2026, 10, 2),
        fields: const {'name': ''},
      );
      await store.enqueue(
        const PendingChange(
          entity: entityProfile,
          syncId: 'u1',
          operation: opUpsert,
          payload: {'name': 'Ana'},
        ),
      );

      await engine.flush();

      expect(remote.pushes, 1);
      expect(store.records['profile/u1']?.fields['name'], 'Ana');
    },
  );
}

class MemorySyncStore implements SyncStore {
  final pendingChanges = <PendingChange>[];
  final records = <String, RemoteRecord>{};

  @override
  Future<void> enqueue(PendingChange change) async {
    pendingChanges.removeWhere(
      (item) => item.entity == change.entity && item.syncId == change.syncId,
    );
    pendingChanges.add(change);
  }

  @override
  Future<List<PendingChange>> pending() async => List.of(pendingChanges);

  @override
  Future<void> removePending(PendingChange change) async {
    pendingChanges.removeWhere(
      (item) => item.entity == change.entity && item.syncId == change.syncId,
    );
  }

  @override
  Future<void> applyRemote(RemoteRecord record) async {
    records['${record.entity}/${record.id}'] = record;
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
  }) async {}
}

class _FakeRemote implements SyncRemote {
  static final serverTime = DateTime.utc(2026, 10, 20, 15);

  final rows = <String, RemoteRecord>{};
  var offline = false;
  var pushes = 0;

  @override
  Future<RemoteRecord?> fetch(String entity, String id) async =>
      rows['$entity/$id'];

  @override
  Future<RemoteRecord> push(PendingChange change) async {
    if (offline) throw StateError('sin red');
    pushes += 1;
    final saved = RemoteRecord(
      entity: change.entity,
      id: change.syncId,
      updatedAt: serverTime,
      deletedAt: change.operation == opDelete ? serverTime : null,
      fields: change.payload,
    );
    rows['${change.entity}/${change.syncId}'] = saved;
    return saved;
  }

  @override
  Future<List<RemoteRecord>> pullProfiles() async => const [];

  @override
  Future<List<RemoteRecord>> pullServices() async => const [];
}
