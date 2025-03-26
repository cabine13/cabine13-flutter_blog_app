import 'package:blog_app/core/errors/failure.dart';
import 'package:blog_app/core/usecases/usecase.dart';
import 'package:blog_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserSignUp implements UseCase<String, UserSignUpParams> {
  const UserSignUp(this.authRepository);
  final AuthRepository authRepository;
  @override
  Future<Either<Failure, String>> call(UserSignUpParams params) async {
    return authRepository.signUpWithEmailPassword(
      name: params.name,
      email: params.email,
      password: params.password,
    );
  }
}

class UserSignUpParams {
  UserSignUpParams({
    required this.email,
    required this.name,
    required this.password,
  });
  final String email;
  final String name;
  final String password;
}
