import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/core/di/di.dart';
import 'package:tracker_app/core/routes/app_route_name.dart';
import 'package:tracker_app/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tracker_app/features/auth/presentation/bloc/update_profile_cubit.dart';
import 'package:tracker_app/features/auth/presentation/screen/login_screen.dart';
import 'package:tracker_app/features/auth/presentation/screen/profile_setup_screen.dart';
import 'package:tracker_app/features/auth/presentation/screen/sign_up_screen.dart';
import 'package:tracker_app/features/expense/presentation/bloc/expense_cubit.dart';
import 'package:tracker_app/features/expense/presentation/screens/add_expense_view.dart';
import 'package:tracker_app/features/expense/presentation/screens/expense_history_view.dart';
import 'package:tracker_app/features/home/presentation/screen/home_screen.dart';

// ── Singleton cubit — created once, shared across home + all sub-routes ──────
// This is the key fix: one instance lives outside GoRouter so every route
// that needs ExpenseCubit gets the SAME instance via BlocProvider.value()
 
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: FirebaseAuth.instance.currentUser != null
        ? AppRouteName.home
        : AppRouteName.login,

    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loc = state.matchedLocation;
      final isPureAuthRoute =
          loc == AppRouteName.login || loc == AppRouteName.signup;
      if (user == null && !isPureAuthRoute) return AppRouteName.login;
      if (user != null && isPureAuthRoute) return AppRouteName.home;
      return null;
    },

    routes: [
      GoRoute(
        path: AppRouteName.login,
        name: AppRouteName.login,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthCubit>(), // fresh instance from factory
          child: const LoginScrren(),
        ),
      ),
      GoRoute(
        path: AppRouteName.signup,
        name: AppRouteName.signup,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const SignUpScreen(),
        ),
      ),
      GoRoute(
        path: AppRouteName.profileSetup,
        name: AppRouteName.profileSetup,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ProfileSetupCubit>(),
          child: const ProfileSetupScreen(),
        ),
      ),

      GoRoute(
        path: AppRouteName.home,
        name: AppRouteName.home,
        builder: (context, state) => BlocProvider.value(
          value: sl<ExpenseCubit>(), // same singleton every time
          child: const HomeScreen(),
        ),
        routes: [
          GoRoute(
            path: 'add-expense',
            name: AppRouteName.addExpense,
            builder: (context, state) => BlocProvider.value(
              value: sl<ExpenseCubit>(),
              child: const AddExpenseScreen(),
            ),
          ),
          GoRoute(
            path: 'history',
            name: AppRouteName.expenseHistory,
            builder: (context, state) => BlocProvider.value(
              value: sl<ExpenseCubit>(),
              child: const ExpenseHistoryScreen(),
            ),
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text('Page Not Found'))),
  );
}