class ServiceRecord {
  const ServiceRecord({
    this.id,
    required this.userId,
    required this.type,
    required this.date,
    required this.mileage,
    required this.notes,
    required this.category,
  });

  final int? id;
  final String userId;
  final String type;
  final String date;
  final int mileage;
  final String notes;
  final String category;

  ServiceRecord copyWith({
    int? id,
    String? userId,
    String? type,
    String? date,
    int? mileage,
    String? notes,
    String? category,
  }) {
    return ServiceRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      date: date ?? this.date,
      mileage: mileage ?? this.mileage,
      notes: notes ?? this.notes,
      category: category ?? this.category,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'userId': userId,
        'type': type,
        'date': date,
        'mileage': mileage,
        'notes': notes,
        'category': category,
      };

  factory ServiceRecord.fromMap(Map<String, Object?> map) {
    return ServiceRecord(
      id: map['id'] as int?,
      userId: map['userId']! as String,
      type: map['type']! as String,
      date: map['date']! as String,
      mileage: map['mileage']! as int,
      notes: map['notes']! as String,
      category: map['category']! as String,
    );
  }
}

const serviceTypes = <String>[
  'Cambio de Aceite',
  'Ajuste de Cadena',
  'Cambio de Llantas',
  'Revisión de Frenos',
  'Servicio General',
];

const serviceCategories = <String>['Urgente', 'Preventivo', 'Garantía'];
