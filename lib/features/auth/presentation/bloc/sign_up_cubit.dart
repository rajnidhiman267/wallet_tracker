import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker_app/features/auth/domain/usecases/auth_usecase.dart';

import 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthUseCase authUseCase;

  SignUpCubit({required this.authUseCase}) : super(const SignUpState());

  Future<void> signUp({required String email, required String password}) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

    var result=  await authUseCase.signUpCall(email: email, password: password);

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
}
