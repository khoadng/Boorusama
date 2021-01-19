import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/bloc/authentication_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/users/i_user_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final IAccountRepository _accountRepository;
  final IUserRepository _userRepository;
  final AuthenticationBloc _authenticationBloc;
  final ISettingRepository _settingRepository;
  StreamSubscription _streamUserSubscription;

  UserBloc({
    @required IAccountRepository accountRepository,
    @required IUserRepository userRepository,
    @required AuthenticationBloc authenticationBloc,
    @required ISettingRepository settingRepository,
  })  : _accountRepository = accountRepository,
        _userRepository = userRepository,
        _authenticationBloc = authenticationBloc,
        _settingRepository = settingRepository,
        super(UserEmpty()) {
    _streamUserSubscription = _authenticationBloc.listen((state) {
      if (state is Authenticated) {
        add(UserRequested());
      }
    });
  }

  @override
  Stream<UserState> mapEventToState(
    UserEvent event,
  ) async* {
    if (event is UserRequested) {
      yield UserLoading();
      final account = await _accountRepository.get();
      final user = await _userRepository.getUserById(account.id);
      //TODO: WARNING error prone code, need serialization
      final settings = await _settingRepository.load();
      settings.blacklistedTags = user.blacklistedTags.join("\n");
      await _settingRepository.save(settings);
      yield UserFetched(user: user);
    }
  }

  @override
  Future<void> close() {
    _streamUserSubscription.cancel();
    return super.close();
  }
}
