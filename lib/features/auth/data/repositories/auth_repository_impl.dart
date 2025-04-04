import 'package:blog_app/core/errors/exception.dart';
import 'package:blog_app/core/errors/failure.dart';
import 'package:blog_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blog_app/features/auth/domain/entities/app_user.dart';
import 'package:blog_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.remoteDataSource);

  final AuthRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, AppUser>> LoginWithEmailPassword({
    required String email,
    required String password,
  }) {
    // TODO: implement LoginWithEmailPassword
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, AppUser>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final appUser = await remoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
      );

      return right(appUser);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
