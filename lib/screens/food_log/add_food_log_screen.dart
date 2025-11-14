import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../services/food_api_service.dart';
import '../../models/food_log.dart';

class AddFoodLogScreen extends StatefulWidget {
  const AddFoodLogScreen({super.key});

  @override
  State<AddFoodLogScreen> createState() => _AddFoodLogScreenState();
}

class _AddFoodLogScreenState extends State<AddFoodLogScreen> {
  final _foodController = TextEditingController();
  final _amountController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  final FoodApiService _apiService = FoodApiService();

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  bool _loading = false;

  void _submit() async {
    final foodName = _foodController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (foodName.isEmpty || amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    setState(() => _loading = true);

    // API trả calories theo grams
    final totalCalories = await _apiService.getCalories(foodName, amount) ?? 0;

    final log = FoodLog(
      id: "",
      foodName: foodName,
      amountGram: amount,
      calories: totalCalories,
      date: DateTime.now(),
      source: "manual",
    );

    await _firestoreService.addFoodLog(userId, log);

    setState(() => _loading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm món ăn"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tên món ăn
            TextField(
              controller: _foodController,
              decoration: const InputDecoration(
                labelText: "Tên món",
                prefixIcon: Icon(Icons.fastfood),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Gram
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: "Số gram",
                prefixIcon: Icon(Icons.scale),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),

            // Nút lưu
            _loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.check),
                      label: const Text("Lưu món ăn"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
