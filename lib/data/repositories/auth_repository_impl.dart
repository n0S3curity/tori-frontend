import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/secure_storage_service.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource, this._storage);

  final AuthRemoteDataSource _dataSource;
  final SecureStorageService _storage;
  // On web, google_sign_in_web requires the OAuth clientId explicitly.
  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: kIsWeb ? googleClientId : null,
  );

  @override
  Future<Either<Failure, ({UserEntity user, String token})>> googleLogin({
    required String role,
    String? businessName,
  }) async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return left(const Failure.unknown(message: 'Sign in cancelled'));

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) return left(const Failure.unknown(message: 'No ID token'));

      final data = await _dataSource.googleLogin(
        idToken: idToken,
        role: role,
        businessName: businessName,
      );

      final token = data['token'] as String;
      final userMap = data['user'] as Map<String, dynamic>;
      final userModel = UserModel.fromJson(userMap);

      await _storage.saveJwt(token);
      await _storage.saveUser(jsonEncode(userMap));
      return right((user: userModel.toEntity(), token: token));
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  /// Returns the user restored from local cache, or null if cache is missing/corrupt.
  Future<UserEntity?> getCachedUser() async {
    try {
      final userJson = await _storage.getUser();
      if (userJson == null) return null;
      return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>)
          .toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<Either<Failure, UserEntity>> updateProfile(
      Map<String, dynamic> data) async {
    try {
      final userModel = await _dataSource.updateProfile(data);
      // Persist updated user to local cache
      await _storage.saveUser(jsonEncode(userModel.toJson()));
      return right(userModel.toEntity());
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _dataSource.logout();
      await _storage.clearAll();
      await _googleSignIn.signOut();
      return right(unit);
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp({
    required String phone,
    required String sessionInfo,
    required String code,
  }) async {
    try {
      final userModel = await _dataSource.verifyOtp(
        phone: phone,
        sessionInfo: sessionInfo,
        code: code,
      );
      // Persist the updated user (now with phoneVerified: true) so that
      // checkAuth() on the next app launch restores the correct state.
      await _storage.saveUser(jsonEncode(userModel.toJson()));
      return right(userModel.toEntity());
    } on DioException catch (e) {
      return left(e.error is Failure ? e.error as Failure : const Failure.unknown());
    }
  }
}

extension _UserModelMapper on UserModel {
  UserEntity toEntity() => UserEntity(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        phoneVerified: phoneVerified,
        profileImage: profileImage,
        role: role,
        language: language,
        isDisabled: isDisabled,
      );
}
