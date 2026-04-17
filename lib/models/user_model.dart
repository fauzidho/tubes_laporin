class UserModel {
  final String id;
  final String name;
  final String nim;
  final String prodi;
  final String email;
  final bool isAdmin;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.nim,
    required this.prodi,
    required this.email,
    this.isAdmin = false,
    required this.createdAt,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? nim,
    String? prodi,
    String? email,
    bool? isAdmin,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nim: nim ?? this.nim,
      prodi: prodi ?? this.prodi,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nim': nim,
      'prodi': prodi,
      'email': email,
      'isAdmin': isAdmin,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    // Handling timestamp parsing safely
    DateTime parsedDate = DateTime.now();
    if (map['createdAt'] != null) {
      if (map['createdAt'] is String) {
        parsedDate = DateTime.parse(map['createdAt']);
      } else {
        // Assume it's a Firestore Timestamp
        parsedDate = map['createdAt'].toDate();
      }
    }

    return UserModel(
      id: id,
      name: map['name'] ?? '',
      nim: map['nim'] ?? '',
      prodi: map['prodi'] ?? '',
      email: map['email'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      createdAt: parsedDate,
    );
  }
}
