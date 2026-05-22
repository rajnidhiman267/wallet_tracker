class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  AuthState copyWith({bool? isLoading, String? errorMessage, bool? isSuccess}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
