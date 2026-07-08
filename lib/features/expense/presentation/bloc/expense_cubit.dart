import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker_app/features/expense/data/model/expense_model.dart';
import 'package:tracker_app/features/expense/domain/usecase/expense_usecase.dart';
import 'package:tracker_app/features/expense/presentation/bloc/expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseUseCase expenseUseCase;
  StreamSubscription<List<ExpenseModel>>? _expenseSubscription;

  ExpenseCubit({required this.expenseUseCase}) : super(const ExpenseState()) {
    _startWatching();
  }

  void _startWatching() {
    // Cancel any existing subscription before starting a new one
    _expenseSubscription?.cancel();

    _expenseSubscription = expenseUseCase.watchExpenses().listen(
      (expenses) {
        final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
        emit(
          state.copyWith(
            expenses: expenses,
            totalAmount: total,
            isLoading: false,
            errorMessage: null,
          ),
        );
      },
      onError: (e) {
        debugPrint('💥 watchExpenses stream error: $e');
        emit(state.copyWith(errorMessage: e.toString(), isLoading: false));

        // SAFETY NET: If the stream errors (e.g. network blip), restart it
        // after a short delay so the UI never gets permanently stuck.
        Future.delayed(const Duration(seconds: 3), () {
          if (!isClosed) _startWatching();
        });
      },
      // cancelOnError: false means the subscription stays alive even after
      // an error event — combined with the restart above this is belt+braces
      cancelOnError: false,
    );
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    String? note,
  }) async {
    try {
      emit(
        state.copyWith(isAdding: true, addSuccess: false, errorMessage: null),
      );

      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isEmpty) throw Exception('Not authenticated');

      final expense = ExpenseModel(
        uid: uid,
        title: title,
        amount: amount,
        category: category,
        date: date,
        note: note,
        createdAt: DateTime.now(),
      );

      await expenseUseCase.addExpense(expense);

      // The Firestore stream will automatically push the new expense back
      // to HomeScreen — we only need to signal the add screen to pop.
      emit(state.copyWith(isAdding: false, addSuccess: true));
    } catch (e) {
      debugPrint('💥 addExpense error: $e');
      emit(state.copyWith(isAdding: false, errorMessage: e.toString()));
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await expenseUseCase.deleteExpense(id);
      // Stream will auto-update — no manual state change needed
    } catch (e) {
      debugPrint('💥 deleteExpense error: $e');
      emit(state.copyWith(errorMessage: 'Failed to delete expense.'));
    }
  }

  Future<void> loadByFilter(ExpenseFilter filter) async {
    try {
      emit(state.copyWith(isLoading: true, filter: filter, errorMessage: null));
      List<ExpenseModel> expenses;
      if (filter == ExpenseFilter.week) {
        expenses = await expenseUseCase.getWeeklyExpenses();
      } else {
        expenses = await expenseUseCase.getMonthlyExpenses();
      }
      final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
      emit(
        state.copyWith(
          expenses: expenses,
          totalAmount: total,
          isLoading: false,
        ),
      );
    } catch (e) {
      debugPrint('💥 loadByFilter error: $e');
      emit(state.copyWith(isLoading: false, errorMessage: 'Failed to load.'));
    }
  }

  void resetAddSuccess() {
    emit(state.copyWith(addSuccess: false));
  }

  @override
  Future<void> close() {
    _expenseSubscription?.cancel();
    return super.close();
  }
}
