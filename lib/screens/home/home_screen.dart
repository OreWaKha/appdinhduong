import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/food_log.dart';
import 'week_summary_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  DateTime selectedDate = DateTime.now();

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ===== WEEK SUMMARY =====
          WeekSummaryWidget(userId: userId),

          // ===== DATE PICKER =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                const Text(
                  "Ngày:",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                  child: Text(
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),

          // ===== FOOD LOG LIST =====
          Expanded(
            child: StreamBuilder<List<FoodLog>>(
              stream:
                  _firestoreService.getLogsByDate(userId, selectedDate),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Lỗi tải dữ liệu"),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final logs = snapshot.data!;

                if (logs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Chưa có dữ liệu hôm nay",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: logs.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final log = logs[index];

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Colors.orange.shade100,
                          child: const Icon(
                            Icons.fastfood,
                            color: Colors.orange,
                          ),
                        ),
                        title: Text(
                          log.foodName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "${log.amountGram} g • ${log.calories.toStringAsFixed(0)} kcal",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              "/edit_food_log",
                              arguments: {
                              "log": log,
                              "userId": userId,
                            },
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ===== ADD BUTTON =====
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/add_food_log");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
