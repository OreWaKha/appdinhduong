import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_log.dart';
import '../models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------- FOOD LOG ----------
  Future<void> addFoodLog(String uid, FoodLog log) async {
    await _db.collection('users').doc(uid).collection('food_logs').add(log.toMap());
  }

  Future<void> updateFoodLog(String uid, FoodLog log) async {
    await _db.collection('users').doc(uid).collection('food_logs').doc(log.id).update(log.toMap());
  }

  Future<void> deleteFoodLog(String uid, String logId) async {
    await _db.collection('users').doc(uid).collection('food_logs').doc(logId).delete();
  }

  // Lấy tất cả food logs
  Future<List<FoodLog>> getFoodLogs(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('food_logs')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FoodLog.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Stream logs theo ngày
  Stream<List<FoodLog>> getLogsByDate(String uid, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return _db
        .collection('users')
        .doc(uid)
        .collection('food_logs')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FoodLog.fromMap(doc.id, doc.data())).toList());
  }

  // Stream logs theo khoảng ngày
  Stream<List<FoodLog>> getLogsInRange(String uid, DateTime start, DateTime end) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('food_logs')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FoodLog.fromMap(doc.id, doc.data())).toList());
  }

  Future<List<FoodLog>> getLogsByDateOnce(String uid, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('food_logs')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end)
        .orderBy('date')
        .get();

    return snapshot.docs.map((doc) => FoodLog.fromMap(doc.id, doc.data())).toList();
  }

  // ---------- USER PROFILE ----------
  Future<UserProfile?> getUserProfile(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).collection('profile').doc('main').get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<void> updateUserProfile(String uid, UserProfile profile) async {
    await _db.collection('users').doc(uid).collection('profile').doc('main').set(profile.toMap(), SetOptions(merge: true));
  }
}
