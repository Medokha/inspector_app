class User {
  const User({
    required this.id,
    required this.inspectorId,
    required this.name,
    required this.email,
    required this.roles,
  });

  final String id;
  final String inspectorId;
  final String name;
  final String email;
  final List<String> roles;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      inspectorId: json['inspectorId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inspectorId': inspectorId,
      'name': name,
      'email': email,
      'roles': roles,
    };
  }
}
