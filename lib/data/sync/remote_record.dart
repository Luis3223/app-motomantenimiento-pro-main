/// Fila tal como la devolvió Postgres.
class RemoteRecord {
  const RemoteRecord({
    required this.entity,
    required this.id,
    required this.updatedAt,
    required this.fields,
    this.deletedAt,
  });

  final String entity;
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Map<String, Object?> fields;
}
