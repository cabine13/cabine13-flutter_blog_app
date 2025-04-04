import 'package:blog_app/features/auth/domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  AppUserModel({
    required super.id,
    required super.email,
    required super.name,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> map) {
    return AppUserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
    );
  }
}
