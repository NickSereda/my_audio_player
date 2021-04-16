import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../audio_player_repository.dart';

part 'audio_player_state.dart';

class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final AudioPlayerRepository audioPlayerRepository = AudioPlayerRepository();

  AudioPlayerCubit() : super(AudioPlayerInitial());

  Future<void> getAudioTracks() async {
    try {
      emit(AudioPlayerLoading());

      final List<MediaItem> audioTracks =
          audioPlayerRepository.fetchAudioTracks();

      emit(AudioPlayerLoaded(audioTracks));
    } on TimeoutException {
      emit(AudioPlayerFailure(
        title: "Network error",
        message: "Failed to download audio tracks",
      ));
    } on SocketException {
      emit(AudioPlayerFailure(
        title: "Network error",
        message: "Failed to download audio tracks",
      ));
    } catch (e) {
      debugPrint(e.toString());
      emit(AudioPlayerFailure(
        title: "Error",
        message: "There was an error while trying to open audio tracks.",
      ));
    }
  }
}
