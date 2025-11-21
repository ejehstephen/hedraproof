class User {
  final String id;
  final String name;
  final String email;
  final String walletAddress;
  final String token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.walletAddress,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // It's safer to handle potential nulls from the API response
    final userMap = json['user'] as Map<String, dynamic>? ?? {};

    return User(
      id: userMap['_id'] ?? '',
      name: userMap['name'] ?? '',
      email: userMap['email'] ?? '',
      walletAddress: userMap['walletAddress'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': {
        '_id': id,
        'name': name,
        'email': email,
        'walletAddress': walletAddress,
      },
      'token': token,
    };
  }
}
