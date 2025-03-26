part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  AuthSuccess(this.uid);
  final String uid;
}

final class AuthFailure extends AuthState {
  AuthFailure(this.message);
  final String message;
}
