import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/core/routes/app_route_name.dart';
import 'package:tracker_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:tracker_app/features/auth/data/repository/auth_repository_impl.dart';
import 'package:tracker_app/features/auth/presentation/bloc/auth_cubit.dart';
 import 'package:tracker_app/features/auth/presentation/bloc/update_profile_cubit.dart';
import 'package:tracker_app/features/auth/presentation/screen/login_screen.dart';
import 'package:tracker_app/features/auth/presentation/screen/profile_setup_screen.dart';
import 'package:tracker_app/features/auth/presentation/screen/sign_up_screen.dart';
import 'package:tracker_app/features/home/presentation/screen/home_screen.dart';

import '../../features/auth/domain/usecases/auth_usecase.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: FirebaseAuth.instance.currentUser != null
        ? AppRouteName.home
        : AppRouteName.login,

    // debugLogDiagnostics: true,
    // redirect: (context, state) {
    //   final user = FirebaseAuth.instance.currentUser;

    //   final isLoginRoute = state.matchedLocation == AppRouteName.login;

    //   if (user == null && !isLoginRoute) {
    //     return AppRouteName.login;
    //   }

    //   if (user != null && isLoginRoute) {
    //     return AppRouteName.home;
    //   }

    //   return null;
    // },
    routes: [
      /// LOGIN
      GoRoute(
        path: AppRouteName.login,
        name: AppRouteName.login,
        builder: (context, state) {
          return BlocProvider(
            create: (context) => AuthCubit(
              authUseCase: AuthUseCase(
                authRepository: AuthRepositoryImpl(
                  authRemoteDataSource: AuthRemoteDatasource(
                    firebaseAuth: FirebaseAuth.instance,
                    firestore: FirebaseFirestore.instance,
                  ),
                ),
              ),
            ),
            child: const LoginScrren(),
          );
        },
      ),

      /// REGISTER
      GoRoute(
        path: AppRouteName.signup,
        name: AppRouteName.signup,
        builder: (context, state) {
          final authRemoteDataSource = AuthRemoteDatasource(
            firebaseAuth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,
          );

          final authRepository = AuthRepositoryImpl(
            authRemoteDataSource: authRemoteDataSource,
          );

          final signUpUseCase = AuthUseCase(authRepository: authRepository);
          return BlocProvider(
            create: (_) => AuthCubit(authUseCase: signUpUseCase),
            child: const SignUpScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRouteName.profileSetup,
        name: AppRouteName.profileSetup,
        builder: (context, state) => BlocProvider(
          create: (context) => ProfileSetupCubit(
            updateProfileUseCase: AuthUseCase(
              authRepository: AuthRepositoryImpl(
                authRemoteDataSource: AuthRemoteDatasource(
                  firebaseAuth: FirebaseAuth.instance,
                  firestore: FirebaseFirestore.instance,
                ),
              ),
            ),
          ),
          child: const ProfileSetupScreen(),
        ),
      ),
      GoRoute(
        path: AppRouteName.home,
        name: AppRouteName.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],

    errorBuilder: (context, state) {
      return const Scaffold(body: Center(child: Text("Page Not Found")));
    },
  );
}
