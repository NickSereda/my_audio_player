import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class BackgroundAudioTaskHandler extends BaseAudioHandler
    with WidgetsBindingObserver {
  final AudioPlayer _player = AudioPlayer();

  final List<MediaItem> tracksQueue;

  BackgroundAudioTaskHandler({
    required this.tracksQueue,
  }) {
    _init();
  }

  StreamSubscription<int?>? _currentIndexStreamSubscription;
  StreamSubscription<SequenceState?>? _sequenceStateStreamSubscription;
  StreamSubscription<PlaybackEvent>? _playbackEventStreamSubscription;
  StreamSubscription? _errorStreamSubscription;

  BehaviorSubject<Duration?> get durationStream =>
      _player.durationStream as BehaviorSubject<Duration?>;

  BehaviorSubject<Duration> get positionStream =>
      _player.positionStream as BehaviorSubject<Duration>;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      stop().then((value) => customAction('dispose'));
    }
  }

  Future<void> _init() async {
    queue.add(tracksQueue);
    await _loadPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    await _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
    WidgetsBinding.instance!.addObserver(this);
  }

  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  Future<void> _loadPlaylist() async {
    try {
      final List<AudioSource> list = [];

      if (defaultTargetPlatform == TargetPlatform.android) {
        for (int i = 0; i < queue.value.length; i++) {
          final name = queue.value[i].id;
          if (name.startsWith('asset')) {
            AudioSource audio = AudioSource.uri(Uri.parse(name),
                tag: queue.value[i]);
            list.add(audio);
          } else {
            AudioSource audio = LockCachingAudioSource(Uri.parse(name),
                tag: queue.value[i]);
            list.add(audio);
          }
        }
      } else {
        for (int i = 0; i < queue.value.length; i++) {
          final name = queue.value[i].id;
          AudioSource audio = AudioSource.uri(Uri.parse(name),
              tag: queue.value[i]);
          list.add(audio);
        }
      }

      _playlist = ConcatenatingAudioSource(children: list);

      await _player
          .setAudioSource(_playlist)
          .onError((dynamic error, stackTrace) async {
        for (int i = 0; i < _playlist.children.length; i++) {
          bool hasError = true;

          await _player
              .setAudioSource(_playlist, initialIndex: i)
              .then((_) => hasError = false)
              .onError((dynamic error, stackTrace) => hasError = true);

          // i > 4 ensures there are no memory pressure
          if (hasError == false || i > 4) {
            break;
          }
        }
        return;
      });
    } catch (e) {

    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _playbackEventStreamSubscription =
        _player.playbackEventStream.listen((PlaybackEvent event) {
          final playing = _player.playing;
          playbackState.add(playbackState.value.copyWith(
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
            }[_player.processingState]!,
            repeatMode: const {
              LoopMode.off: AudioServiceRepeatMode.none,
              LoopMode.one: AudioServiceRepeatMode.one,
              LoopMode.all: AudioServiceRepeatMode.all,
            }[_player.loopMode]!,
            shuffleMode: (_player.shuffleModeEnabled)
                ? AudioServiceShuffleMode.all
                : AudioServiceShuffleMode.none,
            playing: playing,
            updatePosition: _player.position,
            bufferedPosition: _player.bufferedPosition,
            speed: _player.speed,
            queueIndex: event.currentIndex!,
          ));
        });
  }

  Future<void> _listenForCurrentSongIndexChanges() async {
    _currentIndexStreamSubscription =
        _player.currentIndexStream.listen((index) async {
          final playlist = queue;
          if (index == null || await playlist.isEmpty) return;
          if (_player.shuffleModeEnabled) {
            index = _player.shuffleIndices![index];
          }
          mediaItem.add(playlist.value[index]);
        });
  }

  void _listenForSequenceStateChanges() {
    _sequenceStateStreamSubscription =
        _player.sequenceStateStream.listen((SequenceState? sequenceState) {
          final sequence = sequenceState?.effectiveSequence;
          if (sequence == null || sequence.isEmpty) return;
          final List<MediaItem> items = sequence.map((source) => source.tag).toList() as List<MediaItem>;
          queue.add(items);
        });
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // manage Just Audio
    final audioSource = mediaItems.map(_createAudioSource);
    _playlist.addAll(audioSource.toList());

    // notify system
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    // manage Just Audio
    final audioSource = _createAudioSource(mediaItem);
    await _playlist.add(audioSource);

    // notify system
    final newQueue = queue.value..add(mediaItem);
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
    final newQueue = queue.value..removeAt(index);
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
    if (index < 0 || index >= queue.value.length) return;
    if (_player.shuffleModeEnabled) {
      index = _player.shuffleIndices![index];
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
    if (newPosition > _player.duration!)
      newPosition = _player.duration!;
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
  Future customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
      _currentIndexStreamSubscription?.cancel();
      _sequenceStateStreamSubscription?.cancel();
      _errorStreamSubscription?.cancel();
      _playbackEventStreamSubscription?.cancel();

      WidgetsBinding.instance!.removeObserver(this);

      super.stop();
    }

    if (name == "loadBackgroundImage") {
      int? index = _player.playbackEvent.currentIndex;

      //int index = _player.durationStream.last;
      final List<MediaItem?> newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }
      final oldMediaItem = newQueue[index]!;
      final MediaItem? newMediaItem =
      oldMediaItem.copyWith(artUri: Uri.parse(extras!["path"] as String));

      newQueue[index] = newMediaItem;
      queue.add(newQueue as List<MediaItem>);
      mediaItem.add(newMediaItem);
    }

  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

}
