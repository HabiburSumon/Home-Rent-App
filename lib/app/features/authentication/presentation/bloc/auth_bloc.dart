import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:agentic_ai/app/core/errors/exceptions.dart';
import 'package:agentic_ai/app/features/authentication/domain/entities/user.dart';
import 'package:agentic_ai/app/features/authentication/domain/usecases/get_logged_in_user.dart';
import 'package:agentic_ai/app/features/authentication/domain/usecases/login_user.dart';
import 'package:agentic_ai/app/features/authentication/domain/usecases/logout_user.dart';
import 'package:agentic_ai/app/features/authentication/domain/usecases/register_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LogoutUser logoutUser;
  final GetLoggedInUser getLoggedInUser;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
    required this.logoutUser,
    required this.getLoggedInUser,
  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLoginEvent);
    on<RegisterEvent>(_onRegisterEvent);
    on<LogoutEvent>(_onLogoutEvent);
    on<GetLoggedInUserEvent>(_onGetLoggedInUserEvent);
  }

  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUser(LoginUserParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onRegisterEvent(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await registerUser(RegisterUserParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onLogoutEvent(LogoutEvent event, Emitter<AuthState> emit) async {
    final result = await logoutUser(NoParams());
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> _onGetLoggedInUserEvent(GetLoggedInUserEvent event, Emitter<AuthState> emit) async {
    final result = await getLoggedInUser(NoParams());
    result.fold(
      (failure) => emit(Unauthenticated()),
      (user) => emit(Authenticated(user: user)),
    );
  }

  String _mapFailureToMessage(dynamic failure) {
    if (failure is ServerException) {
      return failure.message;
    } else if (failure is CacheException) {
      return failure.message;
    } else {
      return 'Unexpected error';
    }
  }
}