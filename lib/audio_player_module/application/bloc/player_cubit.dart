import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:my_audio_player/audio_player_module/infrastructure/background_tasks/audio_player_background_task.dart';
import 'package:my_audio_player/audio_player_module/infrastructure/services/tracks_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_cubit.freezed.dart';

part 'player_state.dart';

Future<AudioHandler> initAudioService({
  required List<MediaItem> tracks,
}) async {
  return await AudioService.init(
    builder: () {
      return BackgroundAudioTaskHandler(
        tracksQueue: tracks,
      );
    },
    config: AudioServiceConfig(
      androidNotificationChannelName: 'Audio Service Demo',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class ActiveAudioPlayerRxState {
  final MediaItem? mediaItem;
  final List<MediaItem> queue;
  final PlaybackState playbackState;

  ActiveAudioPlayerRxState(
    this.mediaItem,
    this.queue,
    this.playbackState,
  );
}

@injectable
class PlayerCubit extends Cubit<AudioPlayerState> {
  PlayerCubit(this._tracksService)
      : super(
          AudioPlayerState(
            loopMode: LoopMode.off,
            position: Duration.zero,
            currentMediaItem: null,
            queue: [],
            currentIndex: 0,
            playerStatus: PlayerStatus.initial,
            playing: false,
            duration: Duration.zero,
            speed: 1.0,
            processingState: AudioProcessingState.idle,
          ),
        ) {
    _tracksStreamSubscription = _tracksService.tracksStream.listen((tracks) {
      if (tracks != null && tracks.isNotEmpty) {
        setUpAudioTracks(tracks: tracks);
      }
    });
  }

  final TracksService _tracksService;

  late final StreamSubscription<List<MediaItem>?> _tracksStreamSubscription;

  StreamSubscription<Duration?>? _durationStreamSubscription;

  StreamSubscription<Duration>? _positionStreamSubscription;

  /// StreamSubscription that creates 1 custom stream and emits [ActivePlayerState].
  StreamSubscription? _playerStreamSubscription;

  /// StreamSubscription that changes playing property of the [AudioPlayerState]
  StreamSubscription? _playingStreamSubscription;

  /// StreamSubscription that catches error property of the [AudioPlayerState]
  StreamSubscription? _errorStreamSubscription;

  BackgroundAudioTaskHandler? _audioHandler;



  Future<void> setUpAudioTracks({
    required List<MediaItem> tracks,
  }) async {
    // Creating audioHandler
    _audioHandler = await initAudioService(
      tracks: tracks,
    ).catchError((onError) {
      // Todo:- Handle error here
    }) as BackgroundAudioTaskHandler;

    _getPlayerStreamSubscription();

    _getPlayingStreamSubscription();

    _getDurationAndPositionStreamSubscription();
  }

  /// This method connects [AudioService] streams into 1 custom stream and emits [ActivePlayerState].
  void _getPlayerStreamSubscription() {
    if (_audioHandler != null) {
      _playerStreamSubscription = Rx.combineLatest3<MediaItem?, List<MediaItem>,
              PlaybackState, ActiveAudioPlayerRxState>(
          _audioHandler!.mediaItem,
          _audioHandler!.queue,
          _audioHandler!.playbackState,
          (mediaItem, queue, playbackState) =>
              ActiveAudioPlayerRxState(mediaItem, queue, playbackState)).listen(
        (rxState) {
          final MediaItem? currentMediaItem = rxState.mediaItem;

          int currentIndex = 0;

          if (rxState.mediaItem != null) {
            currentIndex = rxState.queue
                .indexWhere((element) => element.id == currentMediaItem?.id);
          }

          if (currentMediaItem != null) {
            emit(
              state.copyWith(
                currentMediaItem: currentMediaItem,
                currentIndex: currentIndex,
                queue: rxState.queue,
                processingState: rxState.playbackState.processingState,
              ),
            );
          }
        },
      );
    }
  }

  void _getPlayingStreamSubscription() {
    _playingStreamSubscription = _audioHandler?.playbackState
        .map((state) => state.playing)
        .distinct()
        .listen(
      (playing) {
        emit(state.copyWith(
          playing: playing,
        ));
      },
    );
  }

  void play() {
    _audioHandler?.play();
    emit(state.copyWith(playing: true));
  }

  void pausePlayer() {
    _audioHandler?.pause();
    emit(state.copyWith(
      playing: false,
    ));
  }

  /// Method is used in [PreviousTrackButton] in audio widgets.
  ///
  /// if it returns null, button becomes disabled.
  Function()? skipToPrevious(AudioPlayerState playerState) {
    if (playerState.currentMediaItem == null || playerState.queue.isEmpty) {
      return null;
    }
    if (playerState.currentMediaItem == playerState.queue.first) {
      return null;
    }

    return _audioHandler?.skipToPrevious;
  }

  /// Method is used in [NextTrackButton] in audio widgets.
  ///
  /// if it returns null, button becomes disabled.
  Function()? skipToNext(AudioPlayerState activePlayerState) {
    if (activePlayerState.currentMediaItem == null ||
        activePlayerState.queue.isEmpty) {
      return null;
    }
    if (activePlayerState.currentMediaItem == activePlayerState.queue.last) {
      return null;
    }

    return _audioHandler?.skipToNext;
  }

  Future<void> seekTo(Duration duration) async {
    await _audioHandler?.seek(duration);
  }

  void setSpeed(double speed) {
    _audioHandler?.setSpeed(speed);
    emit(state.copyWith(speed: speed));
  }

  void toggleLoopMode() {
    if (state.loopMode == LoopMode.off) {
      _audioHandler?.setRepeatMode(AudioServiceRepeatMode.one);
      emit(state.copyWith(loopMode: LoopMode.one));
    } else {
      _audioHandler?.setRepeatMode(AudioServiceRepeatMode.none);
      emit(state.copyWith(loopMode: LoopMode.off));
    }
  }

  Future<void> skipToQueueItem(int index) async {
    await _audioHandler?.skipToQueueItem(index);
  }

  void rewind() {
    _audioHandler!.rewind();
  }

  void fastForward() {
    _audioHandler!.fastForward();
  }

  Future<void> activateOrPlay() async {
    if (state.processingState == AudioProcessingState.idle) {
      // is triggered when we stop on background and play again
      setUpAudioTracks(
        tracks: state.queue,
      );
    } else {
      play();
    }
  }

  void _changeDuration(Duration duration) {
    emit(state.copyWith(duration: duration));
  }

// Getting duration and position stream subscriptions.
  Future<void> _getDurationAndPositionStreamSubscription() async {
    _durationStreamSubscription = _audioHandler?.durationStream.listen(
      (duration) {
        if (duration == null) {
          _changeDuration(Duration.zero);
        } else {
          _changeDuration(duration);
        }
      },
    );

    _positionStreamSubscription = _audioHandler?.positionStream.listen(
      (position) {
        emit(state.copyWith(position: position));
      },
    );
  }

  @override
  Future<void> close() {
    _playerStreamSubscription?.cancel();
    _playingStreamSubscription?.cancel();
    _durationStreamSubscription?.cancel();
    _positionStreamSubscription?.cancel();
    _errorStreamSubscription?.cancel();
    _tracksStreamSubscription.cancel();
    return super.close();
  }

}
