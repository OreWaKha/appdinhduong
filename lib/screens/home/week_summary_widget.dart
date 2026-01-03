import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/food_log.dart';
import '../../models/user_profile.dart';
import '../../utils/date_utils.dart';

class WeekSummaryWidget extends StatelessWidget {
  final String userId;
  final FirestoreService _firestoreService = FirestoreService();

  WeekSummaryWidget({super.key, required this.userId});

  Color _statusColor(double diff) {
    if (diff > 100) return Colors.red;
    if (diff.abs() <= 100) return Colors.green;
    return Colors.orange;
  }

  String _statusText(double diff) {
    if (diff > 100) return "VƯỢT MỨC!";
    if (diff.abs() <= 100) return "ĐẠT MỤC TIÊU";
    return "CHƯA ĐẠT";
  }

  @override
  Widget build(BuildContext context) {
    final startOfWeek = DateHelper.weekStart(DateTime.now());
    final endOfWeek = DateHelper.weekEnd(DateTime.now());

    return FutureBuilder<UserProfile?>(
      future: _firestoreService.getUserProfile(userId),
      builder: (context, profileSnapshot) {
        if (!profileSnapshot.hasData) {
          return const SizedBox(height: 160);
        }

        final weeklyGoal = profileSnapshot.data?.weeklyGoal ?? 14000;

        return StreamBuilder<List<FoodLog>>(
          stream: _firestoreService.getLogsInRange(
              userId, startOfWeek, endOfWeek),
          builder: (context, logSnapshot) {
            if (!logSnapshot.hasData) {
              return const SizedBox(height: 160);
            }

            final logs = logSnapshot.data!;
            final totalCalories =
                logs.fold<double>(0, (sum, log) => sum + log.calories);

            final diff = totalCalories - weeklyGoal;
            final color = _statusColor(diff);
            final progress =
                (totalCalories / weeklyGoal).clamp(0.0, 1.2);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 10,
                      offset: Offset(0, 5),
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // ===== PROGRESS TRÒN =====
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          height: 110,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 10,
                            backgroundColor: Colors.grey.shade300,
                            color: color,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              totalCalories.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "kcal",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(width: 20),

                    // ===== TEXT =====
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tổng calo tuần",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Mục tiêu: $weeklyGoal kcal",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                diff > 100
                                    ? Icons.warning_rounded
                                    : Icons.check_circle,
                                color: color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _statusText(diff),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
