// Interface ----------------------------------------------------------

import 'package:blog_app/core/errors/exception.dart';
import 'package:blog_app/features/auth/data/models/app_user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Future<AppUserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });
  Future<AppUserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });
}

// Implementation -----------------------------------------------------

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this.supabaseClient);

  final SupabaseClient supabaseClient;

  @override
  Future<AppUserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) {
    // TODO: implement loginWithEmailPassword
    throw UnimplementedError();
  }

  @override
  Future<AppUserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {
          'name': name,
        },
      );

      if (response.user == null) {
        throw const ServerException('User is null!');
      }

      return AppUserModel.fromJson(response.user!.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
