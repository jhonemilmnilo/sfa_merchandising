class AppUser {
  final int userId;
  final String email;
  final String password; // prototype only; later replace with token-based auth
  final String firstName;
  final String middleName;
  final String lastName;
  final String position;
  final String? imagePath;

  const AppUser({
    required this.userId,
    required this.email,
    required this.password,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.position,
    this.imagePath,
  });

  String get fullName {
    final m = middleName.trim();
    if (m.isEmpty) return "$firstName $lastName".trim();
    return "$firstName $m $lastName".trim();
  }

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "user_email": email,
        "user_password": password,
        "user_fname": firstName,
        "user_mname": middleName,
        "user_lname": lastName,
        "user_position": position,
        "user_image": imagePath,
      };

  factory AppUser.fromJson(Map<String, dynamic> j) {
    return AppUser(
      userId: (j["user_id"] ?? 0) as int,
      email: (j["user_email"] ?? "") as String,
      password: (j["user_password"] ?? "") as String,
      firstName: (j["user_fname"] ?? "") as String,
      middleName: (j["user_mname"] ?? "") as String,
      lastName: (j["user_lname"] ?? "") as String,
      position: (j["user_position"] ?? "") as String,
      imagePath: j["user_image"] as String?,
    );
  }
}
