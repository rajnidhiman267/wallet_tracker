import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker_app/features/auth/domain/usecases/auth_usecase.dart';
import 'package:tracker_app/features/auth/presentation/bloc/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthUseCase authUseCase;

  AuthCubit({required this.authUseCase}) : super(const AuthState());

  // ── Call on login screen init ────────────────────────────────────────────
  // Shows the biometric button only when user has a saved session AND hardware
  // is available.  This correctly models "biometric registration".
  Future<void> checkBiometricAvailability() async {
    final registered = await authUseCase.isBiometricRegistered();
    emit(state.copyWith(isBiometricAvailable: registered));
  }

  // ── Biometric login ──────────────────────────────────────────────────────
  Future<void> loginWithBiometric() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      final authenticated = await authUseCase.authenticateWithBiometric();
      if (!authenticated) {
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Biometric authentication failed.'));
        return;
      }

      // Biometric passed — Firebase session is persistent, just check it exists
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
      } else {
        // Session expired — ask user to log in with email/password once
        emit(state.copyWith(
          isLoading: false,
          errorMessage:
              'Session expired. Please sign in with email or Google once.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Biometric error: $e'));
    }
  }

  // ── Email / password login ───────────────────────────────────────────────
  Future<void> login({required String email, required String password}) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await authUseCase.loginCall(email: email, password: password);
      // datasource already called registerBiometric() on success
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: _mapFirebaseError(e)));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Something went wrong.'));
    }
  }

  // ── Sign-up ──────────────────────────────────────────────────────────────
  // After sign-up the user goes to ProfileSetupScreen, NOT home.
  // isSuccess = true signals the screen to navigate to /profileSetup.
  Future<void> signUp({required String email, required String password}) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await authUseCase.signUpCall(email: email, password: password);
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: _mapSignUpError(e)));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Something went wrong.'));
    }
  }

  // ── Google sign-in ───────────────────────────────────────────────────────
  Future<void> signInWithGoogleRequested() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null, isSuccess: false));
      await authUseCase.signInWithGoogleCall();
      // datasource already called registerBiometric() on success
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      emit(state.copyWith(
          isLoading: false, isSuccess: false, errorMessage: '$e'));
    }
  }

  // ── Sign-out ─────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await authUseCase.signOut(); // clears biometric flag + Firebase session
    emit(const AuthState());
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return e.message ?? 'Something went wrong.';
    }
  }

  String _mapSignUpError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return e.message ?? 'Something went wrong.';
    }
  }
}
