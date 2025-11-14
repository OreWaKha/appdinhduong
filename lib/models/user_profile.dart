class UserProfile {
  final String name;
  final int weeklyGoal;

  UserProfile({required this.name, required this.weeklyGoal});

  Map<String, dynamic> toMap() {
    return {'name': name, 'weeklyGoal': weeklyGoal};
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      weeklyGoal: map['weeklyGoal'] ?? 14000,
    );
  }
}
