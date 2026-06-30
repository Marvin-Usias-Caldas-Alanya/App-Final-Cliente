class AuthState {
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

String? emailFromDni(String dni) {
  switch (dni.trim()) {
    case '45678912':
      return 'cliente001@confianza.local';
    case '71234567':
      return 'cliente002@confianza.local';
    default:
      if (dni.trim().length >= 8) {
        return '${dni.trim()}@confianza.local';
      }
      return null;
  }
}
