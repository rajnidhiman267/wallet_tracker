import 'package:tracker_app/features/expense/data/model/expense_model.dart';
import 'package:tracker_app/features/expense/domain/repository/expense_repository.dart';

class ExpenseUseCase {
  final ExpenseRepository repository;

  ExpenseUseCase({required this.repository});

  Future<void> addExpense(ExpenseModel expense) =>
      repository.addExpense(expense);

  Future<void> deleteExpense(String id) => repository.deleteExpense(id);

  Future<List<ExpenseModel>> getWeeklyExpenses() =>
      repository.fetchWeeklyExpenses();

  Future<List<ExpenseModel>> getMonthlyExpenses() =>
      repository.fetchMonthlyExpenses();

  Future<List<ExpenseModel>> getExpensesByDateRange({
    required DateTime from,
    required DateTime to,
  }) =>
      repository.fetchExpensesByDateRange(from: from, to: to);

  Stream<List<ExpenseModel>> watchExpenses() => repository.watchRecentExpenses();
}