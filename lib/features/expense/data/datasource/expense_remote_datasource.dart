import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker_app/features/expense/data/model/expense_model.dart';

class ExpenseRemoteDatasource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  ExpenseRemoteDatasource({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _uid => firebaseAuth.currentUser?.uid ?? '';

  CollectionReference get _collection =>
      firestore.collection('users').doc(_uid).collection('expenses');

  Future<void> addExpense(ExpenseModel expense) async {
    await _collection.add(expense.toJson());
  }

  Future<void> deleteExpense(String id) async {
    await _collection.doc(id).delete();
  }

  Future<List<ExpenseModel>> fetchExpensesByDateRange({
    required DateTime from,
    required DateTime to,
  }) async {
    // FIX: Removed .orderBy() — Firestore needs a composite index for
    // where() + orderBy() even on the same field. Sort in Dart instead.
    final snapshot = await _collection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(to))
        .get();

    final list = snapshot.docs
        .map((doc) => ExpenseModel.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ))
        .toList();

    list.sort((a, b) => b.date.compareTo(a.date)); // sort descending in Dart
    return list;
  }

  Future<List<ExpenseModel>> fetchWeeklyExpenses() async {
    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );
    final weekEnd = weekStart.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
    return fetchExpensesByDateRange(from: weekStart, to: weekEnd);
  }

  Future<List<ExpenseModel>> fetchMonthlyExpenses() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1)
        .subtract(const Duration(seconds: 1));
    return fetchExpensesByDateRange(from: monthStart, to: monthEnd);
  }

  // THE REAL FIX:
  // Old code: .where(...).orderBy(...).snapshots()
  // → Firestore throws "requires composite index" exception on the stream
  // → StreamSubscription receives the error, onError fires once, then the
  //   stream closes permanently
  // → No more updates ever reach the cubit even after writing new data
  //
  // Fix: Remove .orderBy() entirely from the Firestore query.
  // Sort the list in Dart after every snapshot emission instead.
  // A plain .where() on a single field never needs a composite index.
  Stream<List<ExpenseModel>> watchRecentExpenses() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    return _collection
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart),
        )
        // NO .orderBy() here — that's what was killing the stream
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ExpenseModel.fromJson(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  ))
              .toList();

          // Sort descending by date in Dart — always fresh, no index needed
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }
}