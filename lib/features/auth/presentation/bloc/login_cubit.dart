import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker_app/features/auth/domain/usecases/auth_usecase.dart';
import 'package:tracker_app/features/auth/presentation/bloc/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthUseCase authUseCase;
  LoginCubit({required this.authUseCase}) : super(LoginState());

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
}
