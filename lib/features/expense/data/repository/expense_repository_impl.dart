import 'package:tracker_app/features/expense/data/datasource/expense_remote_datasource.dart';
import 'package:tracker_app/features/expense/data/model/expense_model.dart';
import 'package:tracker_app/features/expense/domain/repository/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDatasource datasource;

  ExpenseRepositoryImpl({required this.datasource});

  @override
  Future<void> addExpense(ExpenseModel expense) =>
      datasource.addExpense(expense);

  @override
  Future<void> deleteExpense(String id) => datasource.deleteExpense(id);

  @override
  Future<List<ExpenseModel>> fetchWeeklyExpenses() =>
      datasource.fetchWeeklyExpenses();

  @override
  Future<List<ExpenseModel>> fetchMonthlyExpenses() =>
      datasource.fetchMonthlyExpenses();

  @override
  Future<List<ExpenseModel>> fetchExpensesByDateRange({
    required DateTime from,
    required DateTime to,
  }) =>
      datasource.fetchExpensesByDateRange(from: from, to: to);

  @override
  Stream<List<ExpenseModel>> watchRecentExpenses() =>
      datasource.watchRecentExpenses();
}