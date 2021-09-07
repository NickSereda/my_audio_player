import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:my_audio_player/models/bloc/player_cubit.dart';

import '../audio_player_repository.dart';

part 'tracks_state.dart';

/// Cubit that is responsible for loading tracks from [AudioPlayerRepository].
/// 
/// When tracks are loaded, [TracksLoaded] state is emitted and [PlayerCubit] initializes.
class TracksCubit extends Cubit<TracksState> {

  /// Repository that fetches audio assets or radio links.
  final PlayerRepository audioPlayerRepository;

  static const _noTracksFailure = TracksFailure(
    title: "No audio tracks found",
    message:
    "No audio tracks have been added yet. Please, contact the developer.",
  );

  TracksCubit(this.audioPlayerRepository) : super(TracksInitial());

  Future<dynamic> getAudioTracks() async {
    try {
      emit(TracksLoading());

      final List<MediaItem> audioTracks = audioPlayerRepository.fetchAudioTracks();
      
      if (audioTracks.isEmpty) {
        emit(_noTracksFailure);
      } else {
        emit(TracksLoaded(audioTracks));
        return audioTracks;
      }
    } on TimeoutException {
      emit(TracksFailure(
        title: "Network error",
        message:
        "Failed to download audio tracks. Is the device online?\nOnce downloaded, the audio tracks will be available offline.",
      ));
    } on SocketException {
      emit(TracksFailure(
        title: "Network error",
        message:
        "Failed to download audio tracks. Is the device online?\nOnce downloaded, the audio tracks will be available offline.",
      ));
    } catch (e) {
      debugPrint(e.toString());
      emit(TracksFailure(
        title: "Error",
        message: "There was an error while trying to open audio tracks.",
      ));
    }
  }

}
