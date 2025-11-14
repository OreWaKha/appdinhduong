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
          WeekSummaryWidget(userId: userId),
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
                if (snapshot.hasError) return const Center(child: Text("Lỗi tải dữ liệu"));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final logs = snapshot.data!;
                if (logs.isEmpty) return const Center(child: Text("Chưa có dữ liệu hôm nay"));
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, "/add_food_log");
        },
      ),
    );
  }
}
