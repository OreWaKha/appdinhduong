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
  final user = FirebaseAuth.instance.currentUser!;

  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _weeklyGoalController;

  String _gender = 'male';
  DateTime _birthDate = DateTime(2000);

  bool _loading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _weeklyGoalController = TextEditingController();
    _loadProfile();
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  double _calculateBMR({
    required String gender,
    required double weight,
    required double height,
    required int age,
  }) {
    return gender == 'male'
        ? 10 * weight + 6.25 * height - 5 * age + 5
        : 10 * weight + 6.25 * height - 5 * age - 161;
  }

  Future<void> _loadProfile() async {
    final profile = await _firestoreService.getUserProfile(user.uid);
    if (profile != null) {
      _nameController.text = profile.name;
      _heightController.text = profile.height.toString();
      _weightController.text = profile.weight.toString();
      _weeklyGoalController.text = profile.weeklyGoal.toString();
      _gender = profile.gender;
      _birthDate = profile.birthDate;
    }
    setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    final height = double.tryParse(_heightController.text) ?? 170;
    final weight = double.tryParse(_weightController.text) ?? 60;
    final age = _calculateAge(_birthDate);

    final bmr = _calculateBMR(
      gender: _gender,
      weight: weight,
      height: height,
      age: age,
    );

    final profile = UserProfile(
      name: _nameController.text.trim(),
      email: user.email ?? '',
      gender: _gender,
      birthDate: _birthDate,
      height: height,
      weight: weight,
      weeklyGoal: int.tryParse(_weeklyGoalController.text) ?? 14000,
      bmr: bmr,
    );

    await _firestoreService.updateUserProfile(user.uid, profile);

    setState(() => _isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã lưu thông tin")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trang cá nhân"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ===== MỤC 1: TÀI KHOẢN =====
                  _sectionCard(
                    title: "Thông tin tài khoản",
                    children: [
                      _textField("Tên", _nameController),
                      _readonlyField("Email", user.email ?? ""),
                      _genderPicker(),
                      _birthDatePicker(),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ===== MỤC 2: SỨC KHỎE =====
                  _sectionCard(
                    title: "Hồ sơ sức khỏe & mục tiêu",
                    children: [
                      _numberField("Chiều cao (cm)", _heightController),
                      _numberField("Cân nặng (kg)", _weightController),
                      _numberField("Mục tiêu cal/tuần", _weeklyGoalController),
                      const SizedBox(height: 12),
                      _bmrInfo(),
                    ],
                  ),

                  const SizedBox(height: 32),

                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text("Lưu thông tin"),
                        onPressed: _saveProfile,
                      ),
                    ),

                  const SizedBox(height: 24),

                  OutlinedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text("Đăng xuất"),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                  ),
                ],
              ),
            ),
    );
  }

  // ===== UI COMPONENTS =====

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController c) {
    return TextField(
      controller: c,
      enabled: _isEditing,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _numberField(String label, TextEditingController c) {
    return TextField(
      controller: c,
      enabled: _isEditing,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _readonlyField(String label, String value) {
    return TextField(
      enabled: false, // 🔒 khóa hoàn toàn
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
      ),
      controller: TextEditingController(text: value),
    );
  }

  Widget _genderPicker() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: const InputDecoration(labelText: "Giới tính"),
      items: const [
        DropdownMenuItem(value: 'male', child: Text("Nam")),
        DropdownMenuItem(value: 'female', child: Text("Nữ")),
      ],
      onChanged: _isEditing ? (v) => setState(() => _gender = v!) : null,
    );
  }

  Widget _birthDatePicker() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text("Ngày sinh"),
      subtitle:
          Text("${_birthDate.day}/${_birthDate.month}/${_birthDate.year}"),
      trailing: _isEditing
          ? IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _birthDate,
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _birthDate = date);
              },
            )
          : null,
    );
  }

  Widget _bmrInfo() {
    final age = _calculateAge(_birthDate);
    final height = double.tryParse(_heightController.text) ?? 170;
    final weight = double.tryParse(_weightController.text) ?? 60;
    final bmr = _calculateBMR(
      gender: _gender,
      weight: weight,
      height: height,
      age: age,
    );

    return Text(
      "BMR ước tính: ${bmr.toStringAsFixed(0)} kcal/ngày\n"
      "(lượng calo cơ thể tiêu thụ khi nghỉ ngơi)",
      style: TextStyle(color: Colors.grey.shade700),
    );
  }
}
