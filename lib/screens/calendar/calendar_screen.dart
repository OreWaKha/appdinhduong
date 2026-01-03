import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/food_log.dart';
import '../../models/user_profile.dart';
import '../../services/firestore_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  UserProfile? _profile;

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  bool _expanded = false;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _firestoreService.getUserProfile(userId);
    setState(() => _profile = profile);
  }

  // ===== Helpers for month range =====
  DateTime _monthStart(DateTime day) => DateTime(day.year, day.month, 1);
  DateTime _monthEndExclusive(DateTime day) =>
      DateTime(day.year, day.month + 1, 1);

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  double _totalCalories(List<FoodLog> logs) {
    return logs.fold<double>(0.0, (sum, e) => sum + e.calories);
  }

  Color _statusColor(double total, double bmr) {
    if (total < bmr - 100) return Colors.amber; // thiếu
    if ((total - bmr).abs() <= 100) return Colors.green; // đủ
    return Colors.red; // dư
  }

  String _statusText(double total, double bmr) {
    if (total < bmr - 100) return "CHƯA ĐẠT (thiếu)";
    if ((total - bmr).abs() <= 100) return "ĐẠT MỨC KHUYÊN NGHỊ";
    return "VƯỢT MỨC (dư)";
  }

  void _toggleCalendar() {
    setState(() {
      _expanded = !_expanded;
      _calendarFormat = _expanded ? CalendarFormat.month : CalendarFormat.week;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bmr = _profile!.bmr;

    // Stream logs theo THÁNG (để tô màu calendar)
    final monthStart = _monthStart(_focusedDay);
    final monthEndEx = _monthEndExclusive(_focusedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch dinh dưỡng"),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<List<FoodLog>>(
            stream: _firestoreService.getLogsInRange(
              userId,
              monthStart,
              monthEndEx,
            ),
            builder: (context, monthSnap) {
              final monthLogs = monthSnap.data ?? [];

              // group total calories per day in month
              final Map<DateTime, double> dayTotalMap = {};
              for (final log in monthLogs) {
                final key = _dayKey(log.date);
                dayTotalMap[key] = (dayTotalMap[key] ?? 0) + log.calories;
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ===== Calendar Card =====
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92), 
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 10,
                              offset: Offset(0, 5),
                              color: Colors.black12,
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              // header custom: title + toggle
                              Row(
                                children: [
                                  // ← tháng trước
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: () {
                                      setState(() {
                                        _focusedDay = DateTime(
                                          _focusedDay.year,
                                          _focusedDay.month - 1,
                                          1,
                                        );
                                      });
                                    },
                                  ),

                                  // tháng / năm
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        "${_focusedDay.month}/${_focusedDay.year}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // tháng sau →
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: () {
                                      setState(() {
                                        _focusedDay = DateTime(
                                          _focusedDay.year,
                                          _focusedDay.month + 1,
                                          1,
                                        );
                                      });
                                    },
                                  ),

                                  // nút thu gọn / xem tháng
                                  TextButton.icon(
                                    onPressed: _toggleCalendar,
                                    icon: Icon(
                                      _expanded ? Icons.expand_less : Icons.expand_more,
                                    ),
                                    label: Text(
                                      _expanded ? "Thu gọn" : "Xem tháng",
                                    ),
                                  ),
                                ],
                              ),

                              // legend
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 8, top: 4),
                                child: Row(
                                  children: [
                                    _legendDot(Colors.amber, "Thiếu"),
                                    const SizedBox(width: 12),
                                    _legendDot(Colors.green, "Đạt"),
                                    const SizedBox(width: 12),
                                    _legendDot(Colors.red, "Dư"),
                                  ],
                                ),
                              ),

                              TableCalendar(
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2100, 12, 31),
                                focusedDay: _focusedDay,

                                calendarFormat: _calendarFormat,
                                headerVisible: false, 
                                availableGestures:
                                    AvailableGestures.horizontalSwipe, // đổi tháng
                                selectedDayPredicate: (day) =>
                                    isSameDay(_selectedDay, day),

                                onDaySelected: (selected, focused) {
                                  setState(() {
                                    _selectedDay = selected;
                                    _focusedDay = focused;

                                    // chọn xong tự thu gọn để xem danh sách
                                    _calendarFormat = CalendarFormat.week;
                                    _expanded = false;
                                  });
                                },

                                onPageChanged: (focused) {
                                  setState(() {
                                    _focusedDay = focused;
                                  });
                                },

                                calendarStyle: CalendarStyle(
                                  outsideDaysVisible: false,
                                  todayDecoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  selectedDecoration: const BoxDecoration(
                                    color: Colors.deepPurple,
                                    shape: BoxShape.circle,
                                  ),
                                  defaultTextStyle: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  weekendTextStyle: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                daysOfWeekStyle: const DaysOfWeekStyle(
                                  weekdayStyle: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  weekendStyle: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                calendarBuilders: CalendarBuilders(
                                  defaultBuilder: (context, day, _) {
                                    final key = _dayKey(day);
                                    final total = dayTotalMap[key];

                                    // Không có dữ liệu → để default của TableCalendar
                                    if (total == null) return null;

                                    final color = _statusColor(total, bmr);

                                    return Container(
                                      margin: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.25),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${day.day}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },

                                  // thêm marker nhỏ ở góc để nhìn rõ hơn
                                  markerBuilder: (context, day, events) {
                                    final key = _dayKey(day);
                                    final total = dayTotalMap[key];
                                    if (total == null) return null;

                                    final color = _statusColor(total, bmr);
                                    return Positioned(
                                      bottom: 2,
                                      right: 2,
                                      child: Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
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
                    ),
                  ),

                  // ===== Selected day header =====
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.90),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              "Ngày: ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ===== Content for selected day: chart + list =====
                  SliverToBoxAdapter(
                    child: StreamBuilder<List<FoodLog>>(
                      stream: _firestoreService.getLogsByDate(
                        userId,
                        _selectedDay,
                      ),
                      builder: (context, daySnap) {
                        if (!daySnap.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final logs = daySnap.data!;
                        final total = _totalCalories(logs);
                        final color = _statusColor(total, bmr);
                        final status = _statusText(total, bmr);
                        final progress =
                            (bmr <= 0) ? 0.0 : (total / bmr).clamp(0.0, 1.5);

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Column(
                            children: [
                              _card(
                                child: Row(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 110,
                                          height: 110,
                                          child: CircularProgressIndicator(
                                            value: progress.clamp(0.0, 1.0),
                                            strokeWidth: 10,
                                            backgroundColor:
                                                Colors.grey.shade300,
                                            color: color,
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              total.toStringAsFixed(0),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Text(
                                              "kcal",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Calo so với BMR",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "Đã ăn: ${total.toStringAsFixed(0)} kcal",
                                          ),
                                          Text(
                                            "BMR: ${bmr.toStringAsFixed(0)} kcal",
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(height: 10),
                                          LinearProgressIndicator(
                                            value: progress.clamp(0.0, 1.0),
                                            minHeight: 10,
                                            backgroundColor:
                                                Colors.grey.shade300,
                                            color: color,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            status,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // ===== Mục 1: Danh sách món ăn + cal
                              _card(
                                title: "🍽 Danh sách món ăn",
                                child: logs.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Text("Chưa có dữ liệu"),
                                      )
                                    : Column(
                                        children: logs.map((log) {
                                          return ListTile(
                                            dense: true,
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(
                                              log.foodName,
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w600),
                                            ),
                                            subtitle: Text(
                                                "${log.amountGram} g"),
                                            trailing: Text(
                                              "${log.calories.toStringAsFixed(0)} kcal",
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                              ),

                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _card({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 5),
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
          ],
          child,
        ],
      ),
    );
  }
}
