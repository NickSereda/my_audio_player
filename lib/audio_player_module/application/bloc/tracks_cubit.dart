import 'dart:async';
import 'dart:developer';
import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:my_audio_player/audio_player_module/infrastructure/services/tracks_service.dart';

part 'tracks_state.dart';

@injectable
class TracksCubit extends Cubit<TracksState> {
  final TracksService _tracksService;

  TracksCubit(
    this._tracksService,
  ) : super(
          TracksState(tracksStatus: TracksStatus.initial),
        ) {
    _tracksStreamSubscription = _tracksService.tracksStream.listen((tracks) {
      if (tracks != null) {
        if (tracks.isEmpty) {
          emit(
            state.copyWith(tracksStatus: TracksStatus.tracksEmpty),
          );
        } else {
          emit(
            state.copyWith(tracksStatus: TracksStatus.loaded),
          );
        }
      }
    });
  }

  late final StreamSubscription<List<MediaItem>?> _tracksStreamSubscription;

  Future<void> getAudioTracks() async {
    try {
      emit(
        state.copyWith(tracksStatus: TracksStatus.loading),
      );
      await _tracksService.getTracks();
      log(_tracksService.tracksStream.first.toString());
    } catch (e) {
      debugPrint(e.toString());
      emit(
        state.copyWith(tracksStatus: TracksStatus.error),
      );
    }
  }

  @override
  Future<void> close() {
    _tracksStreamSubscription.cancel();
    return super.close();
  }

}
