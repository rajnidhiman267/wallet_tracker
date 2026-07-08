import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker_app/features/auth/domain/usecases/auth_usecase.dart';
import 'package:tracker_app/features/auth/presentation/bloc/auth_state.dart';

class ProfileSetupCubit extends Cubit<AuthState> {
  final AuthUseCase updateProfileUseCase;

  ProfileSetupCubit({required this.updateProfileUseCase})
      : super(const AuthState());

  Future<void> updateProfile({
    required String name,
    String? photoUrl,
  }) async {
    try {
      // FIX: always reset isSuccess to false before starting so the listener
      // fires again if the user saves a second time in the same session
      emit(state.copyWith(
        isLoading: true,
        isSuccess: false,
        errorMessage: null,
      ));

      await updateProfileUseCase.updateProfileCall(
        name: name,
        // FIX: only pass photoUrl when it's actually set — empty string was
        // overwriting a real photo URL with nothing
        photoUrl: (photoUrl != null && photoUrl.isNotEmpty) ? photoUrl : null,
      );

      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'Failed to update profile: ${e.toString()}',
      ));
    }
  }
}