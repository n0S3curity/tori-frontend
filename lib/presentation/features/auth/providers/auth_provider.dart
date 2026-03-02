import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../data/datasources/local/secure_storage_service.dart';
import '../../../../data/datasources/remote/api_client.dart';
import '../../../../data/datasources/remote/auth_remote_datasource.dart';
import '../../../../data/repositories/auth_repository_impl.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/usecases/auth/google_login_usecase.dart';

// ---------------------------------------------------------------------------
// Infrastructure providers
// ---------------------------------------------------------------------------

final secureStorageProvider = Provider<SecureStorageService>(
  (_) => SecureStorageService(),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(secureStorageProvider);
  return ApiClient(storage);
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.read(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDataSourceProvider),
    ref.read(secureStorageProvider),
  );
});

final googleLoginUseCaseProvider = Provider<GoogleLoginUseCase>((ref) {
  return GoogleLoginUseCase(ref.read(authRepositoryProvider));
});

// ---------------------------------------------------------------------------
// Auth state
// ---------------------------------------------------------------------------

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user, this.token);
  final UserEntity user;
  final String token;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

// ---------------------------------------------------------------------------
// Auth notifier
// ---------------------------------------------------------------------------

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._loginUseCase, this._repository, this._storage)
      : super(const AuthInitial());

  final GoogleLoginUseCase _loginUseCase;
  final AuthRepositoryImpl _repository;
  final SecureStorageService _storage;

  Future<void> checkAuth() async {
    final token = await _storage.getJwt();
    if (token == null) {
      state = const AuthUnauthenticated();
      return;
    }
    // Token exists — restore user from local cache and navigate to home.
    // The auth interceptor will catch any expired tokens on the first API call.
    final cachedUser = await _repository.getCachedUser();
    if (cachedUser == null) {
      // Cache missing or corrupt — force re-login.
      await _storage.clearAll();
      state = const AuthUnauthenticated();
      return;
    }
    state = AuthAuthenticated(cachedUser, token);
  }

  Future<void> loginWithGoogle({
    required String role,
    String? businessName,
  }) async {
    state = const AuthLoading();
    final result = await _loginUseCase(role: role, businessName: businessName);
    result.fold(
      (failure) => state = AuthError(failure.userMessage),
      (data) => state = AuthAuthenticated(data.user, data.token),
    );
  }

  /// Marks phone as verified by sending the Firebase ID token to the backend.
  /// Returns `true` on success, `false` if the backend rejected the token.
  /// Throws if an unexpected error occurs (caller should catch).
  Future<bool> verifyOtp({
    required String phone,
    required String sessionInfo,
    required String code,
  }) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return false;

    final result = await _repository.verifyOtp(
      phone: phone,
      sessionInfo: sessionInfo,
      code: code,
    );

    return result.fold(
      (failure) => false,
      (updatedUser) {
        // Update the in-memory user so the router sees phoneVerified: true
        // and automatically redirects to /home.
        state = AuthAuthenticated(updatedUser, currentState.token);
        return true;
      },
    );
  }

  Future<void> logout() async {
    state = const AuthLoading();
    await _repository.logout();
    state = const AuthUnauthenticated();
  }

  void clearError() {
    if (state is AuthError) state = const AuthUnauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(googleLoginUseCaseProvider),
    ref.read(authRepositoryProvider),
    ref.read(secureStorageProvider),
  );
});

// Convenience selectors
final currentUserProvider = Provider<UserEntity?>((ref) {
  final auth = ref.watch(authProvider);
  return auth is AuthAuthenticated ? auth.user : null;
});

final userRoleProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.role;
});

// Language preference provider
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super(defaultLang) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(langKey) ?? defaultLang;
  }

  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(langKey, lang);
    state = lang;
  }
}
