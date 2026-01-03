import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/firestore_service.dart';
import '../../models/food_log.dart';
import '../../models/user_profile.dart';
import '../food_log/add_food_log_screen.dart';
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

  // ===== XÓA MÓN =====
  Future<void> _confirmDelete(FoodLog log) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa món ăn"),
        content: Text("Bạn chắc chắn muốn xóa '${log.foodName}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Xóa"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestoreService.deleteFoodLog(userId, log.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ===== SMART HINT BMR =====
              SliverToBoxAdapter(
                child: FutureBuilder<UserProfile?>(
                  future: _firestoreService.getUserProfile(userId),
                  builder: (context, snap) {
                    if (!snap.hasData || snap.data == null) {
                      return const SizedBox.shrink();
                    }

                    final profile = snap.data!;
                    final dailyTarget =
                        (profile.weeklyGoal / 7).round();

                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb_outline,
                                color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Gợi ý hôm nay: ~$dailyTarget kcal\n"
                                "BMR: ${profile.bmr.toStringAsFixed(0)} kcal/ngày",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ===== TỔNG CALO TUẦN =====
              SliverToBoxAdapter(
                child: WeekSummaryWidget(userId: userId),
              ),

              // ===== TỔNG CALO NGÀY =====
              SliverToBoxAdapter(
                child: StreamBuilder<List<FoodLog>>(
                  stream: _firestoreService.getLogsByDate(
                      userId, selectedDate),
                  builder: (context, snap) {
                    if (!snap.hasData) return const SizedBox();

                    final total = snap.data!
                        .fold<double>(0, (s, e) => s + e.calories);

                    return _infoCard(
                      title: "Tổng calo ngày",
                      value: "${total.toStringAsFixed(0)} kcal",
                      valueColor: Colors.orange,
                    );
                  },
                ),
              ),

              // ===== CHỌN NGÀY + NÚT ADD =====
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor:
                              Colors.white.withOpacity(0.9),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
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
                      ),
                      const SizedBox(width: 12),

                      /// 🔥 SỬA DUY NHẤT Ở ĐÂY
                      SizedBox(
                        height: 44,
                        width: 44,
                        child: FloatingActionButton(
                          heroTag: "add_food",
                          backgroundColor: Colors.orange,
                          elevation: 4,
                          child: const Icon(Icons.add, size: 22),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddFoodLogScreen(
                                  selectedDate: selectedDate,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ===== DANH SÁCH MÓN =====
              StreamBuilder<List<FoodLog>>(
                stream: _firestoreService.getLogsByDate(
                    userId, selectedDate),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final logs = snap.data!;
                  if (logs.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text("Chưa có dữ liệu")),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final log = logs[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          child: Card(
                            color: Colors.white.withOpacity(0.9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ListTile(
                              title: Text(
                                log.foodName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "${log.amountGram} g • ${log.calories.toStringAsFixed(0)} kcal",
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.orange),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              AddFoodLogScreen(foodLog: log),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _confirmDelete(log),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: logs.length,
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  // ===== CARD INFO =====
  Widget _infoCard({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
