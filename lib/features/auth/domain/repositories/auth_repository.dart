import 'package:blog_app/core/errors/failure.dart';
import 'package:blog_app/features/auth/domain/entities/app_user.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, AppUser>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> LoginWithEmailPassword({
    required String email,
    required String password,
  });
}
