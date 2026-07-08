// lib/core/di/injection_container.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'package:tracker_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:tracker_app/features/auth/data/repository/auth_repository_impl.dart';
import 'package:tracker_app/features/auth/domain/repository/auth_repository.dart';
import 'package:tracker_app/features/auth/domain/usecases/auth_usecase.dart';
import 'package:tracker_app/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tracker_app/features/auth/presentation/bloc/update_profile_cubit.dart';

import 'package:tracker_app/features/expense/data/datasource/expense_remote_datasource.dart';
import 'package:tracker_app/features/expense/data/repository/expense_repository_impl.dart';
import 'package:tracker_app/features/expense/domain/repository/expense_repository.dart';
import 'package:tracker_app/features/expense/domain/usecase/expense_usecase.dart';
import 'package:tracker_app/features/expense/presentation/bloc/expense_cubit.dart';

final GetIt sl = GetIt.instance; // sl = "service locator"

Future<void> initDependencies() async {
  // ── External / Firebase ────────────────────────────────────────────────
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // ── Auth feature ────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasource(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authRemoteDataSource: sl()),
  );

  sl.registerLazySingleton<AuthUseCase>(
    () => AuthUseCase(authRepository: sl()),
  );

  // AuthCubit is short-lived UI state → factory, NOT singleton.
  // Every screen that needs one gets a fresh instance.
  sl.registerFactory<AuthCubit>(() => AuthCubit(authUseCase: sl()));
  sl.registerFactory<ProfileSetupCubit>(
    () => ProfileSetupCubit(updateProfileUseCase: sl()),
  );

  // ── Expense feature ──────────────────────────────────────────────────────
  sl.registerLazySingleton<ExpenseRemoteDatasource>(
    () => ExpenseRemoteDatasource(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );

  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(datasource: sl()),
  );

  sl.registerLazySingleton<ExpenseUseCase>(
    () => ExpenseUseCase(repository: sl()),
  );

  // ExpenseCubit MUST be a singleton — this is the state that needs to
  // persist and stay in sync across Home, AddExpense, and History screens.
  sl.registerLazySingleton<ExpenseCubit>(
    () => ExpenseCubit(expenseUseCase: sl()),
  );
}