# blog_app

[Tuto video](https://www.youtube.com/watch?v=ELFORM9fmss) 
02:09:39

Les pages login et sign up son pretes. On s'occupe du domain.
# Interface Repository
Repo est connecté directement aux usecases
abstract interface class AuthRepository {}
On peut avoir success ou failure => Either (fpdart)
On cree une classe failure (core)
Pour le moment on retourne String en cas de succes. Plus tard ce sera une entité User.

```
Future<Either<Failure, String>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, String>> LoginWithEmailPassword({
    required String email,
    required String password,
  });
  ```

Initialisation supabase
Supabase database password : kUtDZenYcqnDpaah

# Remote data source
data/datasources/auth_remote_data_source.dart
Creer une interface puis la classe datasource
C'est cette classe qui accede directement à la BD

```
abstract interface class AuthRemoteDataSource {
  Future<String> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });
  Future<String> loginWithEmailPassword({
    required String email,
    required String password,
  });
}
```
# Implementation Repository
Creation de auth_repository_impl dans data/repositories
Cette classe appelle les fonctions de AuthRemoteDataSource
```
@override
  Future<String> signUpWithEmailPassword({
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
      return response.user!.id;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
```
# Usecases
1 usecase par action. 
GUI -> bloc -> usecase -> repository -> datasource

# Bloc
## auth_bloc.dart
Changer les imports : 
package:bloc vers package:flutter_bloc/flutter_bloc.dart

## auth_event.dart
La sealed class est immutable => importer material.dart

## auth_state.dart
Créer les classes des etats manquants, heritant de AuthState (comme AuthInitial)
AuthLoading
AuthSuccess
AuthFailure 

## Création du premier event (auth_event.dart) : AuthSignUp
```
sealed class AuthEvent {}
final class AuthSignUp extends AuthEvent {}
```
Cet event AuthSignUp va etre capture dans auth_bloc

## auth_bloc.dart
```
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthSignUp>((event, emit) {
      // fonction
    });
  }
}
```
La fonction doit lancer le usecase. Le usecase prend les parametres email, etc.
Ces parametres viennent du GUI. C'est donc l'event qui doit les porter.
L'event devient : 
```
sealed class AuthEvent {}
final class AuthSignUp extends AuthEvent {
  AuthSignUp({
    required this.email,
    required this.password,
    required this.name,
  });

  final String email;
  final String password;
  final String name;
}
```
Le bloc va au final emettre un state, correspondant au résultat du call du usecase.
Si failure, il faut pouvoir passer le message à Failure
```
@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {}

final class AuthFailure extends AuthState {
  AuthFailure(this.message);
  final String message;
}
```
L'etat AuthSuccess doit aussi renvoyer un objet (String, User, etc.).
```
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
```
Au final, voici le bloc :
```
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required UserSignUp userSignUp,
  })  : _userSignUp = userSignUp,
        super(AuthInitial()) {
    on<AuthSignUp>((event, emit) async {
      final res = await _userSignUp.call(
        UserSignUpParams(
          email: event.email,
          name: event.name,
          password: event.password,
        ),
      );
      res.fold(
        (l) => emit(AuthFailure(l.message)),
        (r) => emit(AuthSuccess(r)),
      );
    });
  }
  final UserSignUp _userSignUp;
}

```
# Config de bloc dans main.dart
Wrap myApp avec un multiblocProvider.
```
runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            userSignUp: UserSignUp(
              AuthRepositoryImpl(
                AuthRemoteDataSourceImpl(supabase.client),
              ),
            ),
          ),
        ),
      ],
      child: const MainApp(),
    ),
  );
```
Trop d'objets imbriqués. On utilisera l'injection de dependances.
## Modification de signup_page
Rajout de onTap dans le AuthGradientButton.
Dans la signUpPage :
  On valide le form
```
onPressed: () {
  if (formKey.currentState!.validate()) {
    context.read<AuthBloc>().add(
      AuthSignUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
      ),
    );
  },
},
```
## Dependency injection - get_it
init_dependencies.dart au meme niveau que main.
Au passage, on initialise aussi supabase dans ce fichier plutot que dans main.
```
final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );
  serviceLocator.registerLazySingleton(() => supabase.client);
}

void _initAuth() {
  serviceLocator.registerFactory<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => UserSignUp(
      serviceLocator(),
    ),
  );
  serviceLocator.registerLazySingleton(
    () => AuthBloc(
      userSignUp: serviceLocator(),
    ),
  );
}
```
Dans l'appli, pour appeler une dependance, on se servira de serviceLocator
```
runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<AuthBloc>(),
        ),
      ],
      child: const MainApp(),
    ),
  );
```