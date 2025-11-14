import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/food_log.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();
  final FirestoreService _firestoreService = FirestoreService();

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text("Chọn ngày: "),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                  child: Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<FoodLog>>(
              stream: _firestoreService.getLogsByDate(userId, selectedDate),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final logs = snapshot.data!;
                if (logs.isEmpty) return const Center(child: Text("Chưa có dữ liệu"));
                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return ListTile(
                      title: Text(log.foodName),
                      subtitle: Text("${log.amountGram} g - ${log.calories} cal"),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
