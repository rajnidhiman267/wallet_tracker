import 'dart:developer';
import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker_app/features/auth/data/model/local_auth_model.dart';
import 'package:tracker_app/features/auth/domain/usecases/auth_usecase.dart';
import 'package:tracker_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthUseCase authUseCase;
  AuthCubit({required this.authUseCase}) : super(AuthState());

  Future<void> login({required String email, required String password}) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      await authUseCase.loginCall(email: email, password: password);

      emit(state.copyWith(isLoading: false, isSuccess: true));
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';

      switch (e.code) {
        case 'invalid-credential':
          errorMessage = 'The credential is not valid.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;

        case 'wrong-password':
          errorMessage = 'Wrong password.';
          break;

        case 'network-request-failed':
          errorMessage = 'No internet connection.';
          break;

        default:
          errorMessage = e.message ?? 'Something went wrong.';
      }
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, errorMessage: 'Something went wrong.'),
      );
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      await authUseCase.signUpCall(email: email, password: password);

      emit(state.copyWith(isLoading: false, isSuccess: true));
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered.';
          break;

        case 'invalid-email':
          errorMessage = 'Please enter a valid email.';
          break;

        case 'weak-password':
          errorMessage = 'Password should be at least 6 characters.';
          break;

        case 'network-request-failed':
          errorMessage = 'No internet connection.';
          break;

        default:
          errorMessage = e.message ?? 'Something went wrong.';
      }

      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, errorMessage: 'Something went wrong.'),
      );
    }
  }

  Future<void> signInWithGoogleRequested() async {
    try {
      // 1. Emit loading state to update UI
      emit(
        state.copyWith(isLoading: true, errorMessage: null, isSuccess: false),
      );

      // 2. Execute the domain boundary use case
      await authUseCase.signInWithGoogleCall();

      // 3. Update the state with success and store the user data if needed
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      // 4. Fallback to failure state on exceptions
      log(e.toString());
      emit(
        state.copyWith(isLoading: false, isSuccess: false, errorMessage: '$e'),
      );
    }
  }
}
