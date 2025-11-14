import 'package:cloud_firestore/cloud_firestore.dart';

class FoodLog {
  final String id;
  final String foodName;
  final double amountGram;
  final double calories;
  final DateTime date;
  final String source;
  final String? imageUrl;

  FoodLog({
    required this.id,
    required this.foodName,
    required this.amountGram,
    required this.calories,
    required this.date,
    required this.source,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'foodName': foodName,
      'amountGram': amountGram,
      'calories': calories,
      'date': date,
      'source': source,
      'imageUrl': imageUrl,
    };
  }

  factory FoodLog.fromMap(String id, Map<String, dynamic> map) {
    return FoodLog(
      id: id,
      foodName: map['foodName'],
      amountGram: (map['amountGram'] as num).toDouble(),
      calories: (map['calories'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      source: map['source'],
      imageUrl: map['imageUrl'],
    );
  }
}
