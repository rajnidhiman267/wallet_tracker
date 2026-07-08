import 'package:tracker_app/features/expense/data/model/expense_model.dart';

abstract class ExpenseRepository {
  Future<void> addExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
  Future<List<ExpenseModel>> fetchWeeklyExpenses();
  Future<List<ExpenseModel>> fetchMonthlyExpenses();
  Future<List<ExpenseModel>> fetchExpensesByDateRange({required DateTime from, required DateTime to});
  Stream<List<ExpenseModel>> watchRecentExpenses();
}