import 'package:bloc_test/bloc_test.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:my_audio_player/audio_player_module/application/bloc/tracks_cubit.dart';
import 'package:my_audio_player/audio_player_module/infrastructure/repositories/test_tracks_repository.dart';
import 'package:my_audio_player/audio_player_module/infrastructure/services/tracks_service.dart';

final getIt = GetIt.instance;

void main() {
  // final testTracks = TestTracksRepository.testAudioList;

  TracksCubit _setUpDependencies() {
    getIt
      ..registerSingleton<TestTracksRepository>(
        TestTracksRepository(),
      )
      ..registerSingleton<TracksService>(
        TracksService(getIt<TestTracksRepository>()),
      );

    return TracksCubit(getIt<TracksService>());
  }

  tearDown(() async {
    await getIt.reset();
  });

  group('Audio Player cubit test', () {
    test('tracks cubit initial state test', () {
      final tracksCubit = _setUpDependencies();
      expect(
        tracksCubit.state,
        TracksState(
          tracksStatus: TracksStatus.initial,
        ),
      );
    });

    blocTest<TracksCubit, TracksState>(
      'TracksCubit emits loading state and loaded state when getAudioTracks() is called',
      build: _setUpDependencies,
      act: (bloc) async {
        await bloc.getAudioTracks();
      },
      expect: () => [
        TracksState(
          tracksStatus: TracksStatus.loading,
        ),
        TracksState(
          tracksStatus: TracksStatus.loaded,
        ),
      ],
    );
  });
}
