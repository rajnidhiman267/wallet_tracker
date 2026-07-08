class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  /// True when: device has biometric hardware AND user has a saved Firebase
  /// session (i.e. they have logged in at least once on this device).
  final bool isBiometricAvailable;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.isBiometricAvailable = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    bool? isBiometricAvailable,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      // Pass null explicitly to clear the error message
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      isBiometricAvailable:
          isBiometricAvailable ?? this.isBiometricAvailable,
    );
  }
}
