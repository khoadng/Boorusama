import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/profile/i_profile_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/profile/profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<AsyncLoadState<Profile>> {
  ProfileCubit({
    required this.profileRepository,
  }) : super(AsyncLoadState.initial());

  final IProfileRepository profileRepository;

  void getProfile() {
    TryAsync<Profile?>(
        action: () => profileRepository.getProfile(),
        onLoading: () => emit(AsyncLoadState.loading()),
        onFailure: (stackTrace, error) => emit(AsyncLoadState.failure()),
        onSuccess: (profile) {
          if (profile == null) {
            emit(AsyncLoadState.failure());
            return;
          }

          emit(AsyncLoadState.success(profile));
        });
  }
}
