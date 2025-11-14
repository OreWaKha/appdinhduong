import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late TextEditingController _nameController;
  late TextEditingController _goalController;
  bool _loading = true;
  bool _isEditing = true; // quản lý chế độ chỉnh sửa

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _goalController = TextEditingController();
    _loadProfile();
  }

  void _loadProfile() async {
    UserProfile? profile = await _firestoreService.getUserProfile(userId);
    if (profile != null) {
      _nameController.text = profile.name;
      _goalController.text = profile.weeklyGoal.toString();
    }
    setState(() {
      _loading = false;
    });
  }

  void _saveProfile() async {
    final name = _nameController.text.trim();
    final goal = int.tryParse(_goalController.text.trim()) ?? 14000;
    UserProfile profile = UserProfile(name: name, weeklyGoal: goal);
    await _firestoreService.updateUserProfile(userId, profile);

    setState(() {
      _isEditing = false; // khóa các TextField sau khi lưu
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã lưu thông tin")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trang cá nhân"),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Card chứa thông tin cá nhân
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tiêu đề và nút sửa
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Thông tin cá nhân",
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (!_isEditing)
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = true; // bật chỉnh sửa
                                    });
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Tên
                          TextField(
                            controller: _nameController,
                            readOnly: !_isEditing,
                            decoration: InputDecoration(
                              labelText: "Tên",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Mục tiêu
                          TextField(
                            controller: _goalController,
                            readOnly: !_isEditing,
                            decoration: InputDecoration(
                              labelText: "Mục tiêu cal/tuần",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.flag),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 24),

                          // Nút lưu chỉ hiện khi đang chỉnh sửa
                          if (_isEditing)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _saveProfile,
                                icon: const Icon(Icons.save),
                                label: const Text("Lưu thông tin"),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Đăng xuất
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(context, "/login");
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text("Đăng xuất"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: theme.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
