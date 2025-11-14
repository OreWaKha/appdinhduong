import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../models/food_log.dart';
import '../../utils/date_utils.dart';

class WeekSummaryWidget extends StatelessWidget {
  final String userId;
  final FirestoreService _firestoreService = FirestoreService();

  WeekSummaryWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    DateTime startOfWeek = DateHelper.weekStart(DateTime.now());
    DateTime endOfWeek = DateHelper.weekEnd(DateTime.now());

    return StreamBuilder<List<FoodLog>>(
      stream: _firestoreService.getLogsInRange(userId, startOfWeek, endOfWeek),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final logs = snapshot.data!;
        final totalCalories = logs.fold<double>(0, (sum, item) => sum + item.calories);

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: ListTile(
              title: const Text("Tổng cal tuần này"),
              subtitle: Text("$totalCalories cal"),
            ),
          ),
        );
      },
    );
  }
}
