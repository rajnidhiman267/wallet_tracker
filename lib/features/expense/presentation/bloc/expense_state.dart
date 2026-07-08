import 'package:tracker_app/features/expense/data/model/expense_model.dart';

enum ExpenseFilter { week, month }

class ExpenseState {
  final bool isLoading;
  final bool isAdding;
  final bool addSuccess;
  final String? errorMessage;
  final List<ExpenseModel> expenses;
  final ExpenseFilter filter;
  final double totalAmount;

  const ExpenseState({
    this.isLoading = false,
    this.isAdding = false,
    this.addSuccess = false,
    this.errorMessage,
    this.expenses = const [],
    this.filter = ExpenseFilter.month,
    this.totalAmount = 0,
  });

  ExpenseState copyWith({
    bool? isLoading,
    bool? isAdding,
    bool? addSuccess,
    String? errorMessage,
    List<ExpenseModel>? expenses,
    ExpenseFilter? filter,
    double? totalAmount,
  }) {
    return ExpenseState(
      isLoading: isLoading ?? this.isLoading,
      isAdding: isAdding ?? this.isAdding,
      addSuccess: addSuccess ?? this.addSuccess,
      errorMessage: errorMessage,
      expenses: expenses ?? this.expenses,
      filter: filter ?? this.filter,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  Map<ExpenseCategory, double> get categoryTotals {
    final Map<ExpenseCategory, double> totals = {};
    for (final e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }
}