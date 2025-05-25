class User {
  final String name;
  final String email;
  final String password;
  UserProfile? profile;

  User({
    required this.name,
    required this.email,
    required this.password,
    this.profile,
  });
}

class UserProfile {
  String? profileImage;
  String? phoneNumber;
  String? address;
  String? bio;
  DateTime? birthDate;

  UserProfile({
    this.profileImage,
    this.phoneNumber,
    this.address,
    this.bio,
    this.birthDate,
  });
}

// Basit bir kullanıcı deposu
class UserRepository {
  static final List<User> _users = [];

  static void addUser(User user) {
    _users.add(user);
  }

  static User? findUserByEmail(String email) {
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  static bool validateUser(String email, String password) {
    return _users.any((user) => user.email == email && user.password == password);
  }

  static void updateUserProfile(String email, UserProfile profile) {
    final user = findUserByEmail(email);
    if (user != null) {
      user.profile = profile;
    }
  }

  static bool hasProfile(String email) {
    final user = findUserByEmail(email);
    return user?.profile != null;
  }
} 