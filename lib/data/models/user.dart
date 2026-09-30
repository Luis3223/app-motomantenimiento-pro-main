class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.bikeModel,
    required this.bikePlate,
    required this.bikeYear,
    required this.bikeVin,
    required this.profileImage,
    this.isAdmin = false,
  });

  final String id;
  final String email;
  final String password;
  final String name;
  final String bikeModel;
  final String bikePlate;
  final String bikeYear;
  final String bikeVin;
  final String profileImage;
  final bool isAdmin;

  AppUser copyWith({
    String? id,
    String? email,
    String? password,
    String? name,
    String? bikeModel,
    String? bikePlate,
    String? bikeYear,
    String? bikeVin,
    String? profileImage,
    bool? isAdmin,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      bikeModel: bikeModel ?? this.bikeModel,
      bikePlate: bikePlate ?? this.bikePlate,
      bikeYear: bikeYear ?? this.bikeYear,
      bikeVin: bikeVin ?? this.bikeVin,
      profileImage: profileImage ?? this.profileImage,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'email': email,
    'password': password,
    'name': name,
    'bikeModel': bikeModel,
    'bikePlate': bikePlate,
    'bikeYear': bikeYear,
    'bikeVin': bikeVin,
    'profileImage': profileImage,
    'isAdmin': isAdmin ? 1 : 0,
  };

  factory AppUser.fromMap(Map<String, Object?> map) {
    return AppUser(
      id: map['id']! as String,
      email: map['email']! as String,
      password: map['password']! as String,
      name: map['name']! as String,
      bikeModel: map['bikeModel']! as String,
      bikePlate: map['bikePlate']! as String,
      bikeYear: map['bikeYear']! as String,
      bikeVin: map['bikeVin']! as String,
      profileImage: map['profileImage']! as String,
      isAdmin: (map['isAdmin'] as int? ?? 0) == 1,
    );
  }
}
