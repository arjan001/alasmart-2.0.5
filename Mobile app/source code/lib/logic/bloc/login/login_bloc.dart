import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/data_provider/remote_url.dart';
import '../../../data/models/auth_response/user_response_model.dart';
import '../../../presentation/errors/errors_model.dart';
import '../../../presentation/errors/failure.dart';
import '../../repository/auth_repository.dart';
import 'login_state_model.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginStateModel> {
  final AuthRepository _authRepository;
  UserResponseModel? _users;

  bool get isLoggedIn => _users != null && _users!.accessToken.isNotEmpty;

  UserResponseModel? get userInformation => _users;

  set saveUserData(UserResponseModel usersData) => _users = usersData;

  LoginBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const LoginStateModel()) {
    on<LoginEventUserEmail>((event, emit) {
      emit(state.copyWith(
          email: event.email, loginState: const LoginStateInitial()));
    });
    on<LoginEventPassword>((event, emit) {
      emit(state.copyWith(
          password: event.password, loginState: const LoginStateInitial()));
    });

    on<LoginEventLanguageCode>((event, emit) {
      print("change login lang ${state.languageCode}");
      emit(state.copyWith(
          languageCode: event.languageCode,
          loginState: const LoginStateInitial()));
    });
    on<LangCodeClear>((event, emit) {
      print('call clear ${state.languageCode}');
      emit(state.copyWith(languageCode: ''));
    });

    on<LoginEventCurrencyIcon>((event, emit) {
      emit(state.copyWith(
          currencyIcon: event.currencyIcon,
          loginState: const LoginStateInitial()));
    });

    on<SaveUserCredentialEvent>((event, emit) {
      emit(state.copyWith(
          isActive: event.isActive, loginState: const LoginStateInitial()));
    });

    on<LoginEventShowPassword>((event, emit) {
      emit(state.copyWith(
          showPassword: !(event.showPassword),
          loginState: const LoginStateInitial()));
    });

    on<LoginEventRememberMe>((event, emit) {
      emit(state.copyWith(
          isRemember: !(event.isRemember),
          loginState: const LoginStateInitial()));
    });

    on<LoginEventSubmit>(_submitLoginEvent);
    on<LoginEventLogout>(_logoutEvent);
    final result = authRepository.getExistingUserInfo();
    result.fold((failure) => _users = null, (success) {
      saveUserData = success;
      print('saveUserData $success');
    });
  }

  Future<void> saveUserCredentials(String email, String password) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('email', email);
    pref.setString('password', password);
  }

  Future<void> _submitLoginEvent(
      LoginEventSubmit event, Emitter<LoginStateModel> emit) async {
    emit(state.copyWith(loginState: LoginStateLoading()));
    final body = state;
    print('login body $body');
    final result = await _authRepository.login(body);
    result.fold(
      (failure) {
        if (failure is InvalidAuthData) {
          final errors = LoginStateFormValidate(failure.errors);
          emit(state.copyWith(loginState: errors));
        } else {
          final errors = LoginStateError(
              message: failure.message, statusCode: failure.statusCode);
          emit(state.copyWith(loginState: errors));
        }
      },
      (success) {
        final userLoaded = LoginStateLoaded(userResponseModel: success);
        _users = success;
        print('uuuuu: $_users');
        emit(state.copyWith(loginState: userLoaded));
        // if (state.isActive == true) {
        //   print('Activeeeeeee');
        //   saveUserCredentials(state.email, state.password);
        // } else {
        //   print('Deactiveeee...');
        // }
        // emit(state.clear());
      },
    );
  }

  Future<void> remoteCredentials() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove('email');
    pref.remove('password');
  }

  Future<void> _logoutEvent(
      LoginEventLogout event, Emitter<LoginStateModel> emit) async {
    emit(state.copyWith(loginState: LoginStateLogoutLoading()));
    final url = Uri.parse(RemoteUrls.logout).replace(queryParameters: {
      'token': userInformation!.accessToken,
      'lang_code': state.languageCode
    });
    debugPrint('logout-params $url');
    final result = await _authRepository.logout(url);
    result.fold(
      (failure) {
        if (failure.statusCode == 500) {
          const loadedData = LoginStateLogoutLoaded('logout success', 200);
          emit(state.copyWith(loginState: loadedData));
        } else {
          final errors =
              LoginStateLogoutError(failure.message, failure.statusCode);
          emit(state.copyWith(loginState: errors));
        }
      },
      (logout) {
        _users = null;
        emit(state.copyWith(loginState: LoginStateLogoutLoaded(logout, 200)));
        //remoteCredentials();
      },
    );
  }
}
