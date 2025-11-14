import 'package:flutter/material.dart';
import '../../models/food_log.dart';
import '../../services/firestore_service.dart';

class EditFoodLogScreen extends StatefulWidget {
  final FoodLog log;
  final String userId;

  const EditFoodLogScreen({super.key, required this.log, required this.userId});

  @override
  State<EditFoodLogScreen> createState() => _EditFoodLogScreenState();
}

class _EditFoodLogScreenState extends State<EditFoodLogScreen> {
  late TextEditingController _foodController;
  late TextEditingController _amountController;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _foodController = TextEditingController(text: widget.log.foodName);
    _amountController = TextEditingController(text: widget.log.amountGram.toString());
  }

  void _save() async {
    final foodName = _foodController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    if (foodName.isEmpty || amount == null) return;

    final updatedLog = FoodLog(
      id: widget.log.id,
      foodName: foodName,
      amountGram: amount,
      calories: widget.log.calories, // hoặc tính lại
      date: widget.log.date,
      source: widget.log.source,
      imageUrl: widget.log.imageUrl,
    );

    await _firestoreService.updateFoodLog(widget.userId, updatedLog);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh sửa món ăn")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _foodController, decoration: const InputDecoration(labelText: "Tên món")),
            TextField(controller: _amountController, decoration: const InputDecoration(labelText: "Số gram"), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text("Lưu")),
          ],
        ),
      ),
    );
  }
}
