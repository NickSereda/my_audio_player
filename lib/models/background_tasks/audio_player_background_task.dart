import 'dart:async';
import 'package:audio_service/audio_service.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:my_audio_player/models/bloc/player_cubit.dart';

/// This task defines logic for playing a list of tracks.
class RegularAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();

  final List<MediaItem> tracksQueue;

  final PlayerCubit playerCubit;

  RegularAudioHandler({
    @required this.tracksQueue,
    @required this.playerCubit,
  }) {
    _init();
  }

  StreamSubscription<Duration> _durationStreamSubscription;
  StreamSubscription<int> _currentIndexStreamSubscription;
  StreamSubscription<SequenceState> _sequenceStateStreamSubscription;
  StreamSubscription _errorStreamSubscription;

  Future<void> _init() async {
    queue.add(tracksQueue);

    await _loadPlaylist();

    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    await _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
    _listenForError();

    playerCubit.getPlayerStreamSubscription();
  }

  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  Future<void> _loadPlaylist() async {
    try {
      final List<AudioSource> list = [];

      if (defaultTargetPlatform == TargetPlatform.android) {
        for (int i = 0; i < queue.valueWrapper.value.length; i++) {
          final name = queue.valueWrapper.value[i].id;
          if (name.startsWith('asset')) {
            AudioSource audio = AudioSource.uri(Uri.parse(name),
                tag: queue.valueWrapper.value[i]);
            list.add(audio);
          } else {
            AudioSource audio = LockCachingAudioSource(Uri.parse(name),
                tag: queue.valueWrapper.value[i]);
            list.add(audio);
          }
        }
      } else {
        for (int i = 0; i < queue.valueWrapper.value.length; i++) {
          final name = queue.valueWrapper.value[i].id;
          AudioSource audio = AudioSource.uri(Uri.parse(name),
              tag: queue.valueWrapper.value[i]);
          list.add(audio);
        }
      }

      _playlist = ConcatenatingAudioSource(children: list);

      await _player.setAudioSource(_playlist);
    } catch (e) {
      playerCubit.emit(
          playerCubit.state.copyWith(activePlayerStatus: PlayerStatus.error));
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.valueWrapper.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState],
        repeatMode: const {
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.one: AudioServiceRepeatMode.one,
          LoopMode.all: AudioServiceRepeatMode.all,
        }[_player.loopMode],
        shuffleMode: (_player.shuffleModeEnabled)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  void _listenForDurationChanges() {
    _durationStreamSubscription =
        _player.durationStream.listen((duration) async {
      int index = _player.playbackEvent.currentIndex;

      //int index = _player.durationStream.last;
      final newQueue = queue.valueWrapper.value;
      if (index == null || newQueue.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices[index];
      }

      // final oldMediaItem = newQueue[index];
      // final newMediaItem = oldMediaItem.copyWith(duration: duration);

      playerCubit.changeDuration(duration);

      // newQueue[index] = newMediaItem;
      //
      // queue.add(newQueue);
      // mediaItem.add(newMediaItem);
    });
  }

  Future<void> _listenForCurrentSongIndexChanges() async {
    _currentIndexStreamSubscription =
        _player.currentIndexStream.listen((index) async {
      final playlist = queue;
      if (index == null || await playlist.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices[index];
      }
      mediaItem.add(playlist.valueWrapper.value[index]);
    });
  }

  void _listenForSequenceStateChanges() {
    _sequenceStateStreamSubscription =
        _player.sequenceStateStream.listen((SequenceState sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((source) => source.tag as MediaItem);
      queue.add(items.toList());
    });
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // manage Just Audio
    final audioSource = mediaItems.map(_createAudioSource);
    _playlist.addAll(audioSource.toList());

    // notify system
    final newQueue = queue.valueWrapper.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    // manage Just Audio
    final audioSource = _createAudioSource(mediaItem);
    await _playlist.add(audioSource);

    // notify system
    final newQueue = queue.valueWrapper.value..add(mediaItem);
    queue.add(newQueue);
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri.parse(mediaItem.id),
      tag: mediaItem,
    );
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    // manage Just Audio
    _playlist.removeAt(index);

    // notify system
    final newQueue = queue.valueWrapper.value..removeAt(index);
    queue.add(newQueue);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.valueWrapper.value.length) return;
    if (_player.shuffleModeEnabled) {
      index = _player.shuffleIndices[index];
    }
    _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> rewind() {
    _seekRelative(const Duration(seconds: -10));
    return super.rewind();
  }

  @override
  Future<void> fastForward() {
    _seekRelative(const Duration(seconds: 10));

    return super.fastForward();
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    return super.setSpeed(speed);
  }

  /// Jumps away from the current position by [offset].
  Future<void> _seekRelative(Duration offset) async {
    var newPosition = _player.position + offset;
    // Make sure we don't jump out of bounds.
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > playerCubit.state.duration)
      newPosition = playerCubit.state.duration;
    // Perform the jump via a seek.
    await _player.seek(newPosition);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.group:
      case AudioServiceRepeatMode.all:
        _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.none) {
      _player.setShuffleModeEnabled(false);
    } else {
      await _player.shuffle();
      _player.setShuffleModeEnabled(true);
    }
  }

  @override
  Future customAction(String name, [Map<String, dynamic> extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
      _durationStreamSubscription?.cancel();
      _currentIndexStreamSubscription?.cancel();
      _sequenceStateStreamSubscription?.cancel();
      _errorStreamSubscription?.cancel();
      super.stop();
    }

    if (name == "loadBackgroundImage") {
      int index = _player.playbackEvent.currentIndex;

      //int index = _player.durationStream.last;
      final newQueue = queue.valueWrapper.value;
      if (index == null || newQueue.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices[index];
      }

      final oldMediaItem = newQueue[index];
      final newMediaItem =
          oldMediaItem.copyWith(artUri: Uri.parse(extras["path"] as String));

      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  bool _handleErrorComplete = true;

  void _listenForError() {
    _errorStreamSubscription = _player.playbackEventStream.listen((event) {},
        // Deleting problem track.
        // Doesn't work on web, instead we handle web errors in onPlay and onSkipToQueueItem.
        // AudioPlayer.playbackEventStream fires multiple error events per audio track.
        onError: (Object error, StackTrace stackTrace) async {
      if (_handleErrorComplete == true) {
        _handleErrorComplete = false;
        await handleError(error);
      }
    });
  }

  Future<void> handleError(Object error) async {
    if (error is PlatformException) {
      int problemSongIndex = _player.playbackEvent.currentIndex;

      if (!kIsWeb) {
        await _playlist.removeAt(problemSongIndex);

        final newQueue = queue.valueWrapper.value..removeAt(problemSongIndex);
        queue.add(newQueue);
      }

      playerCubit.emit(
          playerCubit.state.copyWith(activePlayerStatus: PlayerStatus.error));

      pause();

      skipToQueueItem(0);

      _handleErrorComplete = true;
    }
  }
}
