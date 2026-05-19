import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker_app/features/auth/domain/usecases/auth_usecase.dart';
import 'package:tracker_app/features/auth/presentation/bloc/sign_up_state.dart';

class ProfileSetupCubit extends Cubit<SignUpState> {
  final AuthUseCase updateProfileUseCase;

  ProfileSetupCubit({required this.updateProfileUseCase})
    : super(const SignUpState());

  Future<void> updateProfile({required String name, String? photoUrl}) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      await updateProfileUseCase.updateProfileCall(
        name: name,
        photoUrl: photoUrl,
      );

      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, errorMessage: 'Something went wrong.'),
      );
    }
  }
}
