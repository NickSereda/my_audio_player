import 'dart:async';
import 'dart:developer';
import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:my_audio_player/audio_player_module/application/bloc/player_cubit.dart';
import 'package:my_audio_player/audio_player_module/infrastructure/repositories/audio_player_repository.dart';

part 'tracks_state.dart';

@injectable
class TracksCubit extends Cubit<TracksState> {

  final PlayerRepository audioPlayerRepository;

  final PlayerCubit playerCubit;
  TracksCubit(this.audioPlayerRepository, this.playerCubit)
      : super(TracksState(
          tracksStatus: TracksStatus.initial,
          audioTracks: [],
        ));

  Future<void> getAudioTracks() async {

    try {
      emit(state.copyWith(tracksStatus: TracksStatus.loading));

      final List<MediaItem> audioTracks = await audioPlayerRepository.fetchAudioTracks();

      if (audioTracks.isEmpty) {
        emit(state.copyWith(tracksStatus: TracksStatus.tracksEmpty));
      } else {
        emit(state.copyWith(tracksStatus: TracksStatus.loaded, audioTracks: audioTracks));
        playerCubit.activatePlayer(tracks: audioTracks);
      }
    } catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(tracksStatus: TracksStatus.error));
    }
  }
}
