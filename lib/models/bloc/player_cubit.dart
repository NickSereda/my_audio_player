import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:my_audio_player/models/background_tasks/audio_player_background_task.dart';
import 'package:rxdart/rxdart.dart';
import 'package:path_provider/path_provider.dart';
import '../cover_image_repository.dart';

part 'player_state.dart';

Future<AudioHandler> initAudioService({
  List<MediaItem> tracks,
  PlayerCubit activePlayerCubit,
}) async {
  return await AudioService.init(
    builder: () => RegularAudioHandler(
        tracksQueue: tracks, playerCubit: activePlayerCubit),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.mycompany.myapp.audio',
      androidNotificationChannelName: 'Audio Service Demo',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

/// ActiveAudioPlayerRxState is used to combine all elements of [AudioService] streams into one.
class ActiveAudioPlayerRxState {
  final MediaItem mediaItem;
  final Duration position;
  final List<MediaItem> queue;
  final PlaybackState playbackState;

  ActiveAudioPlayerRxState(
    this.mediaItem,
    this.position,
    this.queue,
    this.playbackState,
  );
}

/// [PlayerCubit] combines [AudioService] streams into one and sets one active player.
///
/// This class ins used to set the main stream in all elements of any player.
class PlayerCubit extends Cubit<PlayerState> {
  /// StreamSubscription that listens navigation and toggles inactive/active state based on navigatorPath and playingPlayerPath.
  StreamSubscription _globalAudioPlayerCubitSubscription;

  /// StreamSubscription that listens to mediaItem changes and sets Cover Image.
  StreamSubscription _mediaItemStreamSubscription;

  /// Repository that fetches Image from audio assets.
  CoverImageRepository _coverImageRepository = CoverImageRepository();

  PlayerCubit()
      : super(
          const PlayerState(
            position: Duration.zero,
            currentMediaItem: null,
            queue: [],
            currentIndex: 0,
            playerStatus: PlayerStatus.initial,
            playing: false,
            duration: Duration.zero,
            coverImage: null,
          ),
        );

  AudioHandler _audioHandler;

  /// StreamSubscription that creates 1 custom stream and emits [PlayerState].
  StreamSubscription _playerStreamSubscription;

  /// StreamSubscription that changes playing property of the [AudioPlayerState]
  StreamSubscription _playingStreamSubscription;

  @override
  Future<void> close() {
    _playerStreamSubscription?.cancel();
    _globalAudioPlayerCubitSubscription?.cancel();
    _playingStreamSubscription?.cancel();
    return super.close();
  }

  void disposeStreams() {
    _playerStreamSubscription?.cancel();
  }

  /// Sets Active Player.
  ///
  /// Loads tracks and starts [AudioService] background task, gets [AudioService] streams.
  Future<void> setActivePlayer({
    List<MediaItem> tracks,
  }) async {
    if (_audioHandler != null) {
      await _audioHandler.customAction('dispose');
    }

    _audioHandler =
        await initAudioService(tracks: tracks, activePlayerCubit: this)
            .catchError((onError) =>
                emit(state.copyWith(activePlayerStatus: PlayerStatus.error)));

    play();

    // gets playing stream
    getPlayingStreamSubscription();

    await resetBackgroundImage();
    // if Type is not AudioPlayerType.regular we don't listen to changes in cover image
    await getCoverImageStreamSubscription();
  }

  /// This method connects [AudioService] streams into 1 custom stream and emits [PlayerState].
  void getPlayerStreamSubscription() {
    _playerStreamSubscription = Rx.combineLatest4<MediaItem, Duration,
            List<MediaItem>, PlaybackState, ActiveAudioPlayerRxState>(
        _audioHandler.mediaItem,
        AudioService.position,
        _audioHandler.queue,
        _audioHandler.playbackState,
        (mediaItem, position, queue, playbackState) => ActiveAudioPlayerRxState(
            mediaItem, position, queue, playbackState)).listen(
      (rxState) {
        final MediaItem currentMediaItem = rxState?.mediaItem;

        int currentIndex = 0;

        if (rxState?.queue != null && rxState?.mediaItem != null) {
          currentIndex = rxState?.queue
              .indexWhere((element) => element?.id == currentMediaItem?.id);
        }

        final PlayerState oldState = state;

        if (rxState?.playbackState?.processingState != null &&
            currentIndex != null &&
            rxState?.queue != null &&
            currentMediaItem != null) {
          emit(
            state.copyWith(
              currentMediaItem: currentMediaItem,
              position: rxState.position ?? Duration.zero,
              currentIndex: currentIndex,
              queue: rxState.queue,
              //activePlayerStatus: ActivePlayerStatus.changed,
              playbackState: rxState.playbackState,
            ),
          );
        }

        _rebuildWidgets(oldState, state);
      },
    );
  }

  /// Activates new player with a new route.
  Future<void> activatePlayer({
    @required List<MediaItem> tracks,
  }) async {
    // Cancel previous StreamSubscription to avoid emitting old stream when activating new player
    _playerStreamSubscription?.cancel();

    _rebuildAllPlayerWidgets();

    await setActivePlayer(
      tracks: tracks,
    );
  }

  void changeDuration(Duration duration) {
    emit(state.copyWith(duration: duration));
    emit(state.copyWith(activePlayerStatus: PlayerStatus.rebuildAudioTimeline));
  }

  void getPlayingStreamSubscription() {
    _playingStreamSubscription = _audioHandler.playbackState
        .map((state) => state.playing)
        .distinct()
        .listen((playing) {
      emit(state.copyWith(
          playing: playing,
          activePlayerStatus: PlayerStatus.rebuildPlaybackControlButtons));
      emit(state.copyWith(
          activePlayerStatus: PlayerStatus.rebuildPlayPauseButton));
    });
  }

  void play() {
    _audioHandler.play();

    emit(state.copyWith(
        playing: true,
        activePlayerStatus: PlayerStatus.rebuildPlaybackControlButtons));
    emit(state.copyWith(
        activePlayerStatus: PlayerStatus.rebuildPlayPauseButton));
  }

  void pausePlayer() {
    _audioHandler?.pause();

    emit(state.copyWith(
        playing: false,
        activePlayerStatus: PlayerStatus.rebuildPlaybackControlButtons));
    emit(state.copyWith(
        activePlayerStatus: PlayerStatus.rebuildPlayPauseButton));
  }

  Future<void> skipToPrevious() async {
    await _audioHandler.skipToPrevious();
  }

  Future<void> skipToNext() async {
    await _audioHandler.skipToNext();
  }

  void seekTo(Duration duration) {
    _audioHandler.seek(duration);
  }

  void setSpeed(double speed) {
    _audioHandler?.setSpeed(speed);
  }

  Stream getSpeedStream() {
    return _audioHandler?.playbackState
        ?.map((event) => event.speed)
        ?.distinct();
  }

  Stream getPlaybackStateStream() {
    return _audioHandler?.playbackState;
  }

  void setRepeatMode(AudioServiceRepeatMode repeatMode) {
    _audioHandler.setRepeatMode(repeatMode);
  }

  Future<void> skipToQueueItem(int index) async {
    await _audioHandler.skipToQueueItem(index);
  }

  Future<void> loadBackgroundImage(String path) async {
    if (_audioHandler != null) {
      await _audioHandler.customAction("loadBackgroundImage", {"path": path});
    }
  }

  Future<void> resetBackgroundImage() async {
    final String path = 'assets/music-icon.png';

    Uint8List bytes;

    final ByteData byteData = await rootBundle.load(path);

    bytes = byteData.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();

    final emptyFile = await File('${tempDir.path}/music.png').create();

    final File file = await emptyFile.writeAsBytes(bytes);

    await _audioHandler.customAction(
        "loadBackgroundImage", {"path": "file:///${file.absolute.path}"});
  }

  Future<void> getCoverImageStreamSubscription() async {
    await resetBackgroundImage();

    // Add timeout not to trigger setBackgroundImage if user presses buttons quickly
    _mediaItemStreamSubscription = _audioHandler?.mediaItem
        ?.distinct()
        ?.timeout(Duration(seconds: 1), onTimeout: (_) async {
      if (state.currentMediaItem.id != null) {
        if (state.currentMediaItem.id.startsWith("https://") ||
            state.currentMediaItem.id.startsWith("http://")) {
          emit(
            state.copyWith(
                coverImage: null, activePlayerStatus: PlayerStatus.imageError),
          );
        } else {
          await resetBackgroundImage();

          emit(state.copyWith(
              coverImage: null, activePlayerStatus: PlayerStatus.imageLoading));

          final List<int> image = await _coverImageRepository.getImage(
              id: state.currentMediaItem.id);

          if (image != null) {
            await _coverImageRepository.setBackgroundImage(
                image: image,
                imageName: state.currentMediaItem.title,
                activePlayerCubit: this);

            emit(state.copyWith(
                coverImage: image,
                activePlayerStatus: PlayerStatus.imageChanged));
          } else {
            emit(state.copyWith(
                coverImage: null, activePlayerStatus: PlayerStatus.imageError));
          }
        }
      }
    })?.listen((event) {});
  }

  // This method is triggered in _playerStreamSubscription and emits rebuild status tells widgets  Rebuilds player widgets
  void _rebuildWidgets(PlayerState prevState, PlayerState currState) {
    if (prevState.currentIndex != currState.currentIndex ||
        prevState.queue != currState.queue) {
      emit(state.copyWith(
          activePlayerStatus: PlayerStatus.rebuildAudioPlayerWidget));
    }

    if (prevState.currentMediaItem != currState.currentMediaItem ||
        prevState.playbackState?.processingState !=
            currState.playbackState?.processingState ||
        prevState.playing != currState.playing) {
      emit(state.copyWith(
          activePlayerStatus: PlayerStatus.rebuildPlaybackControlButtons));
      emit(state.copyWith(
          activePlayerStatus: PlayerStatus.rebuildPlayPauseButton));
    }

    if (prevState.currentMediaItem != currState.currentMediaItem) {
      emit(state.copyWith(activePlayerStatus: PlayerStatus.rebuildLoopButton));
      emit(state.copyWith(
          activePlayerStatus: PlayerStatus.rebuildPreviousTrackButton));
      emit(state.copyWith(
          activePlayerStatus: PlayerStatus.rebuildNextTrackButton));
      emit(state.copyWith(
          activePlayerStatus: PlayerStatus.rebuildTitleArtistWidget));
      emit(state.copyWith(
          activePlayerStatus: PlayerStatus.rebuildSleepTimerButton));
    }

    if (prevState.currentMediaItem != state.currentMediaItem ||
        prevState.position != currState.position) {
      emit(state.copyWith(
          activePlayerStatus: PlayerStatus.rebuildAudioTimeline));
      emit(state.copyWith(
          activePlayerStatus: PlayerStatus.rebuildPlaybackSpeedButton));
    }
  }

  // Rebuilds all player widgets
  void _rebuildAllPlayerWidgets() {
    emit(state.copyWith(
        activePlayerStatus: PlayerStatus.rebuildAudioPlayerWidget));
    emit(state.copyWith(
        activePlayerStatus: PlayerStatus.rebuildPlaybackControlButtons));
    emit(state.copyWith(
        activePlayerStatus: PlayerStatus.rebuildPlayPauseButton));
    emit(state.copyWith(activePlayerStatus: PlayerStatus.rebuildAudioTimeline));
    emit(state.copyWith(
        activePlayerStatus: PlayerStatus.rebuildPlaybackSpeedButton));
    emit(state.copyWith(activePlayerStatus: PlayerStatus.rebuildLoopButton));
    emit(state.copyWith(
        activePlayerStatus: PlayerStatus.rebuildNextTrackButton));
    emit(state.copyWith(
        activePlayerStatus: PlayerStatus.rebuildPreviousTrackButton));
    emit(state.copyWith(
        activePlayerStatus: PlayerStatus.rebuildTitleArtistWidget));
    emit(state.copyWith(
        activePlayerStatus: PlayerStatus.rebuildSleepTimerButton));
  }
}
