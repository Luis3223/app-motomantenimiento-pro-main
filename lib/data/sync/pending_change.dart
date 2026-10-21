import 'dart:convert';

import '../models/service_record.dart';
import '../models/user.dart';

const entityProfile = 'profile';
const entityService = 'service';
const opUpsert = 'upsert';
const opDelete = 'delete';

/// Cambio local aún no confirmado por el servidor.
class PendingChange {
  const PendingChange({
    required this.entity,
    required this.syncId,
    required this.operation,
    required this.payload,
    this.baseUpdatedAt,
  });

  final String entity;
  final String syncId;
  final String operation;
  final Map<String, Object?> payload;

  /// `updated_at` del servidor sobre el que se editó. Nulo si la fila
  /// todavía no se había confirmado.
  final DateTime? baseUpdatedAt;
}

PendingChange profileChange(AppUser user) => PendingChange(
  entity: entityProfile,
  syncId: user.id,
  operation: opUpsert,
  payload: {
    'name': user.name,
    'bike_model': user.bikeModel,
    'bike_plate': user.bikePlate,
    'bike_year': user.bikeYear,
    'bike_vin': user.bikeVin,
    'profile_image': user.profileImage,
  },
  baseUpdatedAt: parseServerTime(user.remoteUpdatedAt),
);

PendingChange serviceChange(
  ServiceRecord service, {
  required String operation,
}) {
  final syncId = service.syncId;
  if (syncId == null || syncId.isEmpty) {
    throw StateError('El servicio no tiene sync_id.');
  }
  return PendingChange(
    entity: entityService,
    syncId: syncId,
    operation: operation,
    payload: {
      'user_id': service.userId,
      'type': service.type,
      'service_date': service.date,
      'mileage': service.mileage,
      'notes': service.notes,
      'category': service.category,
    },
    baseUpdatedAt: parseServerTime(service.remoteUpdatedAt),
  );
}

DateTime? parseServerTime(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.parse(raw).toUtc();
}

String encodePayload(Map<String, Object?> payload) => jsonEncode(payload);

Map<String, Object?> decodePayload(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! Map) return {};
  return decoded.map(
    (key, value) => MapEntry(key.toString(), value as Object?),
  );
}
