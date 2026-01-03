class UserProfile {
  final String name;
  final String email;
  final String gender; // male | female
  final DateTime birthDate;

  final double height; // cm
  final double weight; // kg

  final int weeklyGoal; // cal/tuần
  final double bmr; // cal/ngày

  UserProfile({
    required this.name,
    required this.email,
    required this.gender,
    required this.birthDate,
    required this.height,
    required this.weight,
    required this.weeklyGoal,
    required this.bmr,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'gender': gender,
      'birthDate': birthDate,
      'height': height,
      'weight': weight,
      'weeklyGoal': weeklyGoal,
      'bmr': bmr,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      gender: map['gender'] ?? 'male',
      birthDate: map['birthDate']?.toDate() ?? DateTime(2000),
      height: (map['height'] ?? 170).toDouble(),
      weight: (map['weight'] ?? 60).toDouble(),
      weeklyGoal: map['weeklyGoal'] ?? 14000,
      bmr: (map['bmr'] ?? 0).toDouble(),
    );
  }
}
