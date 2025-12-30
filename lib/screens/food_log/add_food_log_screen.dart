import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../services/food_api_service.dart';
import '../../models/food_log.dart';

class AddFoodLogScreen extends StatefulWidget {
  final FoodLog? foodLog; // null = add, có data = edit

  const AddFoodLogScreen({super.key, this.foodLog});

  @override
  State<AddFoodLogScreen> createState() => _AddFoodLogScreenState();
}

class _AddFoodLogScreenState extends State<AddFoodLogScreen> {
  late TextEditingController _foodController;
  late TextEditingController _amountController;

  final FirestoreService _firestoreService = FirestoreService();
  final FoodApiService _apiService = FoodApiService();

  final String userId = FirebaseAuth.instance.currentUser!.uid;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _foodController = TextEditingController(text: widget.foodLog?.foodName ?? "");
    _amountController = TextEditingController(
        text: widget.foodLog != null ? widget.foodLog!.amountGram.toString() : "");
  }

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

    final totalCalories = await _apiService.getCalories(foodName, amount) ?? 0;

    final log = FoodLog(
      id: widget.foodLog?.id ?? "",
      foodName: foodName,
      amountGram: amount,
      calories: totalCalories,
      date: widget.foodLog?.date ?? DateTime.now(),
      source: widget.foodLog?.source ?? "manual",
      imageUrl: widget.foodLog?.imageUrl,
    );

    if (widget.foodLog == null) {
      await _firestoreService.addFoodLog(userId, log);
    } else {
      await _firestoreService.updateFoodLog(userId, log);
    }

    setState(() => _loading = false);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _foodController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.foodLog != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Chỉnh sửa món ăn" : "Thêm món ăn"),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                color: Colors.white.withOpacity(0.9),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Column(
                        children: const [
                          Icon(
                            Icons.fastfood,
                            size: 48,
                            color: Colors.orange,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Nhập món ăn",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Nhập thông tin món ăn bạn đã dùng",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Food name
                      TextField(
                        controller: _foodController,
                        decoration: InputDecoration(
                          labelText: "Tên món ăn",
                          prefixIcon: const Icon(Icons.restaurant_menu),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Amount
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Khối lượng (gram)",
                          helperText: "Ví dụ: 100",
                          prefixIcon: const Icon(Icons.scale),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Save button
                      SizedBox(
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _loading ? null : _submit,
                          icon: const Icon(Icons.check_circle),
                          label: Text(
                            isEdit ? "Cập nhật món ăn" : "Lưu món ăn",
                            style: const TextStyle(fontSize: 16),
                          ),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Loading overlay
            if (_loading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
