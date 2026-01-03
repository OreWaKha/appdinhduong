import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/firestore_service.dart';
import '../../models/food_log.dart';
import '../../models/user_profile.dart';

enum _ChartMode { bar, pie }

class WeeklyDetailScreen extends StatefulWidget {
  final String userId;
  final DateTime referenceDate; // tuần hiện tại

  const WeeklyDetailScreen({
    super.key,
    required this.userId,
    required this.referenceDate,
  });

  @override
  State<WeeklyDetailScreen> createState() => _WeeklyDetailScreenState();
}

class _WeeklyDetailScreenState extends State<WeeklyDetailScreen> {
  final FirestoreService _firestore = FirestoreService();

  DateTime currentWeekStart = DateTime.now();
  double dailyTarget = 2000;

  // key: 0..6 tương ứng Thứ 2..CN
  Map<int, double> weekCalories = {};
  Map<int, double> prevWeekCalories = {};

  _ChartMode _mode = _ChartMode.bar;

  List<DateTime> getWeekDates(DateTime reference) {
    final monday = reference.subtract(Duration(days: reference.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  Future<void> _loadWeekData() async {
    weekCalories.clear();
    prevWeekCalories.clear();

    final weekDates = getWeekDates(currentWeekStart);
    final prevWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    final prevWeekDates = getWeekDates(prevWeekStart);

    // Tuần hiện tại
    for (int i = 0; i < 7; i++) {
      final logs =
          await _firestore.getLogsByDateOnce(widget.userId, weekDates[i]);
      final total = logs.fold<double>(0.0, (sum, e) => sum + e.calories);
      weekCalories[i] = total;
    }

    // Tuần trước
    for (int i = 0; i < 7; i++) {
      final logs =
          await _firestore.getLogsByDateOnce(widget.userId, prevWeekDates[i]);
      final total = logs.fold<double>(0.0, (sum, e) => sum + e.calories);
      prevWeekCalories[i] = total;
    }

    // Lấy mục tiêu calo từ UserProfile
    final profile = await _firestore.getUserProfile(widget.userId);
    if (profile != null) {
      dailyTarget = profile.weeklyGoal / 7.0;
    }

    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    currentWeekStart = widget.referenceDate
        .subtract(Duration(days: widget.referenceDate.weekday - 1));
    _loadWeekData();
  }

  void previousWeek() {
    setState(() => currentWeekStart = currentWeekStart.subtract(
          const Duration(days: 7),
        ));
    _loadWeekData();
  }

  void nextWeek() {
    setState(() => currentWeekStart = currentWeekStart.add(
          const Duration(days: 7),
        ));
    _loadWeekData();
  }

  void _showDayDetail(DateTime date) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Chi tiết ${date.day}/${date.month}"),
        content: FutureBuilder<List<FoodLog>>(
          future: _firestore.getLogsByDateOnce(widget.userId, date),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final logs = snap.data!;
            if (logs.isEmpty) return const Text("Chưa có dữ liệu");

            return SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: logs
                      .map(
                        (e) => ListTile(
                          dense: true,
                          title: Text(e.foodName),
                          trailing:
                              Text("${e.calories.toStringAsFixed(0)} kcal"),
                        ),
                      )
                      .toList(),
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  double _maxY(List<double> values, double fallback) {
    if (values.isEmpty) return fallback;
    final m = values.reduce((a, b) => a > b ? a : b);
    return (m <= 0 ? fallback : m);
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildBarChart(List<DateTime> weekDates) {
    final cur = List.generate(7, (i) => (weekCalories[i] ?? 0.0));
    final prev = List.generate(7, (i) => (prevWeekCalories[i] ?? 0.0));

    final maxY = _maxY(
          [...cur, ...prev, dailyTarget],
          2000,
        ) *
        1.15;

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),

        // ✅ đường mục tiêu
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: dailyTarget,
              color: Colors.green,
              strokeWidth: 2,
              dashArray: [6, 6],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                labelResolver: (_) => "Target",
              ),
            ),
          ],
        ),

        titlesData: FlTitlesData(
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44, // ✅ đủ chỗ để xoay dọc
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= weekDates.length) return const SizedBox();
                final d = weekDates[i];
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Transform.rotate(
                    angle: -math.pi / 2, // ✅ chữ dọc
                    child: Text(
                      "${d.day}/${d.month}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        barGroups: List.generate(7, (i) {
          // ✅ Cột TRÁI = tuần trước, cột PHẢI = tuần này
          return BarChartGroupData(
            x: i,
            barsSpace: 8,
            barRods: [
              BarChartRodData(
                toY: prev[i],
                color: Colors.blue,
                width: 10,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: cur[i],
                color: Colors.orange,
                width: 10,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),

        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              // rodIndex 0 = tuần trước, 1 = tuần này
              final label = rodIndex == 0 ? "Tuần trước" : "Tuần này";
              return BarTooltipItem(
                "$label: ${rod.toY.toStringAsFixed(0)} kcal",
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          touchCallback: (event, response) {
            // ✅ Chỉ mở detail khi tap thả tay (không bị 2 lần)
            if (event is FlTapUpEvent &&
                response != null &&
                response.spot != null) {
              final index = response.spot!.touchedBarGroupIndex;
              _showDayDetail(weekDates[index]);
            }
          },
        ),
      ),
    );
  }

  Widget _buildPieChart(List<DateTime> weekDates) {
    // Pie: chia theo % calo của TUẦN NÀY theo từng ngày
    final values = List.generate(7, (i) => (weekCalories[i] ?? 0.0));
    final total = values.fold<double>(0.0, (s, e) => s + e);

    if (total <= 0) {
      return const Center(child: Text("Chưa có dữ liệu để vẽ PieChart"));
    }

    final sections = List.generate(7, (i) {
      final v = values[i];
      final percent = (v / total) * 100.0;
      // màu theo i (đơn giản, không set palette cố định)
      final color = HSVColor.fromAHSV(1, (i * 45) % 360.0, 0.65, 0.95).toColor();

      return PieChartSectionData(
        value: v,
        title: "${percent.toStringAsFixed(0)}%",
        radius: 70,
        titleStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        color: color,
      );
    });

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (event is FlTapUpEvent &&
                      response != null &&
                      response.touchedSection != null) {
                    final idx = response.touchedSection!.touchedSectionIndex;
                    _showDayDetail(weekDates[idx]);
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // legend đơn giản
        Wrap(
          spacing: 10,
          runSpacing: 6,
          children: List.generate(7, (i) {
            final d = weekDates[i];
            final color =
                HSVColor.fromAHSV(1, (i * 45) % 360.0, 0.65, 0.95).toColor();
            return _legendDot(color, "${d.day}/${d.month}");
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = getWeekDates(currentWeekStart);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tổng calo tuần"),
        actions: [
          IconButton(
            tooltip: _mode == _ChartMode.bar ? "Chuyển PieChart" : "Chuyển BarChart",
            icon: Icon(_mode == _ChartMode.bar ? Icons.pie_chart : Icons.bar_chart),
            onPressed: () {
              setState(() {
                _mode = _mode == _ChartMode.bar ? _ChartMode.pie : _ChartMode.bar;
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===== Navigation tuần =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: previousWeek,
                      ),
                      Text(
                        "Tuần: ${weekDates.first.day}/${weekDates.first.month} - ${weekDates.last.day}/${weekDates.last.month}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: nextWeek,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ===== Legend + target =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _legendDot(Colors.blue, "Tuần trước"),
                          const SizedBox(width: 12),
                          _legendDot(Colors.orange, "Tuần này"),
                        ],
                      ),
                      Text(
                        "Target/ngày: ${dailyTarget.toStringAsFixed(0)}",
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ===== Chart =====
                  Expanded(
                    child: weekCalories.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : (_mode == _ChartMode.bar
                            ? _buildBarChart(weekDates)
                            : _buildPieChart(weekDates)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
