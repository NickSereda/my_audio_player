import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

/// This task defines logic for playing a list of tracks.
class AudioPlayerTask extends BackgroundAudioTask {
  AudioPlayer _player = AudioPlayer();

  AudioProcessingState _skipState;

  // Seeker _seeker;

  // Allows moving current index
  ConcatenatingAudioSource _concatenatingAudioSource;

  StreamSubscription<PlaybackEvent> _eventSubscription;

  List<MediaItem> _queue = [];

  int get index => _player.currentIndex;

  MediaItem get mediaItem => index == null ? null : _queue[index];

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    _queue.clear();

    List mediaItems = params['data'];
    for (int i = 0; i < mediaItems.length; i++) {
      MediaItem mediaItem = MediaItem.fromJson(mediaItems[i]);
      _queue.add(mediaItem);
    }
    // We configure the audio session for speech since we're playing a podcast.
    // You can also put this in your app's initialisation if your app doesn't
    // switch between two types of audio as this example does.
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
    // Broadcast media item changes.
    _player.currentIndexStream.listen((index) {
      if (index != null) AudioServiceBackground.setMediaItem(_queue[index]);
    });
    // Propagate all events from the audio player to AudioService clients.
    _eventSubscription = _player.playbackEventStream.listen((event) {
      _broadcastState();
    });
    // Setting duration
    _player.durationStream.listen((duration) {
      _updateQueueWithCurrentDuration(duration);
    });
    // Special processing for state transitions.
    _player.processingStateStream.listen((state) {
      switch (state) {
        case ProcessingState.completed:
          // In this example, the service stops when reaching the end.
          onStop();
          break;
        case ProcessingState.ready:
          // If we just came from skipping between tracks, clear the skip
          // state now that we're ready to play.
          _skipState = null;
          break;
        default:
          break;
      }
    });

    // Load and broadcast the queue
    AudioServiceBackground.setQueue(_queue);
    try {
      _concatenatingAudioSource = ConcatenatingAudioSource(
        // shuffleOrder: DefaultShuffleOrder(),
        children:
            _queue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList(),
      );

      await _player.setAudioSource(_concatenatingAudioSource);
      // In this example, we automatically start playing on start.
      //  onPlay();
    } catch (e) {
      print("Error: $e");
      onStop();
    }
  }

  void _updateQueueWithCurrentDuration(Duration duration) {
    final songIndex = _player.playbackEvent.currentIndex;

    //index = songIndex;

    print('current index: $songIndex, duration: $duration');

    final modifiedMediaItem = mediaItem.copyWith(duration: duration);
    _queue[songIndex] = modifiedMediaItem;

    AudioServiceBackground.setMediaItem(_queue[songIndex]);
    AudioServiceBackground.setQueue(_queue);
  }

  @override
  Future<void> onSkipToQueueItem(String mediaId) async {
    // Then default implementations of onSkipToNext and onSkipToPrevious will
    // delegate to this method.
    final newIndex = _queue.indexWhere((item) => item.id == mediaId);
    if (newIndex == -1) return;
    // During a skip, the player may enter the buffering state. We could just
    // propagate that state directly to AudioService clients but AudioService
    // has some more specific states we could use for skipping to next and
    // previous. This variable holds the preferred state to send instead of
    // buffering during a skip, and it is cleared as soon as the player exits
    // buffering (see the listener in onStart).
    _skipState = newIndex > index
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;
    // This jumps to the beginning of the queue item at newIndex.
    _player.seek(Duration.zero, index: newIndex);
    // Demonstrate custom events.
    AudioServiceBackground.sendCustomEvent('skip to $newIndex');
  }

  @override
  Future<void> onPlay() => _player.play();

  @override
  Future<void> onPause() => _player.pause();

  @override
  Future<void> onSeekTo(Duration position) => _player.seek(position);

  @override
  Future<void> onFastForward() => _seekRelative(fastForwardInterval);

  @override
  Future<void> onRewind() => _seekRelative(-rewindInterval);

  @override
  Future<void> onSetSpeed(double speed) => _player.setSpeed(speed);

  // @override
  // Future<void> onSeekForward(bool begin) async => _seekContinuously(begin, 1);
  //
  // @override
  // Future<void> onSeekBackward(bool begin) async => _seekContinuously(begin, -1);

  @override
  Future<void> onSetRepeatMode(AudioServiceRepeatMode repeatMode) {
    if (repeatMode == AudioServiceRepeatMode.none) {
      return _player.setLoopMode(LoopMode.off);
    } else {
      return _player.setLoopMode(LoopMode.one);
    }
  }

  @override
  Future<void> onSetShuffleMode(AudioServiceShuffleMode shuffleMode) {
    if (shuffleMode == AudioServiceShuffleMode.none) {
      return _player.setShuffleModeEnabled(false);
    } else {
      return _player.setShuffleModeEnabled(true);
    }
  }

  // Shuffle
  bool _isInitialAudioIndex = true;

  Map<int, MediaItem> _initialAudioPositions = {};

// Includes initial indexes
  List<int> _initialAudioIndexes = [];

  List<int> shuffledIndexes = [];

  //ShuffleState shuffleState = ShuffleState.InitialState;

  @override
  Future<void> onCustomAction(String name, arguments) async {
    switch (name) {
      case 'seekToTrack':
        await _player.seek(Duration.zero, index: arguments);
        //  AudioServiceBackground.setMediaItem(_queue[arguments]);
        // AudioServiceBackground.sendCustomEvent('skip to $arguments');
        break;

      case 'loadBackgroundImage':
        final songIndex = _player.playbackEvent.currentIndex;

        final modifiedMediaItem =
            mediaItem.copyWith(artUri: Uri.parse(arguments as String));

        _queue[songIndex] = modifiedMediaItem;
        AudioServiceBackground.setMediaItem(_queue[songIndex]);
        AudioServiceBackground.setQueue(_queue);

        break;

      case 'shuffle':
        if (_isInitialAudioIndex) {
          // Saving initial audios
          _queue.asMap().entries.forEach((element) {
            _initialAudioPositions[element.key] = element.value;
          });

          _initialAudioIndexes =
              List<int>.generate(_initialAudioPositions.length, (i) => i);

          print("_initialAudioPositions $_initialAudioIndexes");

          _isInitialAudioIndex = false;
        }

        if (arguments == false) {
          final int currentIndex = _player.playbackEvent.currentIndex;
          //All audios except the current one.
          final List<MediaItem> audiosToShuffle = [];

          final playlistLength = _queue.length;

          // Before current index
          for (int i = 0; i < currentIndex; i++) {
            final removedAudio = _queue.removeAt(0);

            audiosToShuffle.add(removedAudio);
          }

          // After current index
          for (int i = currentIndex + 1; i < playlistLength; i++) {
            final removedAudio = _queue.removeAt(1);
            audiosToShuffle.add(removedAudio);
          }

          audiosToShuffle.shuffle();

          _queue.addAll(audiosToShuffle);

          // Getting shuffled indexes
          shuffledIndexes = [];

          _queue.forEach((audio) {
            int index = _initialAudioPositions.entries
                .firstWhere((element) => element.value == audio)
                .key;
            shuffledIndexes.add(index);
          });

          print("shuffledIndexes: $shuffledIndexes");

          _concatenatingAudioSource.move(currentIndex, 0);

          AudioServiceBackground.setQueue(_queue);
        } else {
          final playlistLength = _queue.length;

          final int currentIndex = _player.playbackEvent.currentIndex;

          final audioIndexInInitialPlaylist = shuffledIndexes[currentIndex];

          print("sameAudioIndex $audioIndexInInitialPlaylist");

          // 1. Remove old(shuffled) audios before current index
          for (int i = 0; i < currentIndex; i++) {
            _queue.removeAt(0);
          }

          // 3. Remove old(shuffled) audios after current index
          for (int i = currentIndex + 1; i < playlistLength; i++) {
            _queue.removeAt(1);
          }

          // // 2. Insert new(initial) audios before current index
          for (int i = audioIndexInInitialPlaylist - 1; i >= 0; i--) {
            _queue.insert(0, _initialAudioPositions[i]);
          }

          // 4. Insert new(initial) audios after current index
          for (int i = audioIndexInInitialPlaylist + 1;
              i < playlistLength;
              i++) {
            _queue.add(_initialAudioPositions[i]);
          }
          _concatenatingAudioSource.move(
              currentIndex, audioIndexInInitialPlaylist);

          AudioServiceBackground.setQueue(_queue);
        }

        break;
    }
  }

  @override
  Future<void> onStop() async {
    _player.stop();
    await _player.dispose();
    _eventSubscription.cancel();
    // It is important to wait for this state to be broadcast before we shut
    // down the task. If we don't, the background task will be destroyed before
    // the message gets sent to the UI.
    await _broadcastState();
    // Shut down this task
    await super.onStop();
  }

  /// Jumps away from the current position by [offset].
  Future<void> _seekRelative(Duration offset) async {
    var newPosition = _player.position + offset;
    // Make sure we don't jump out of bounds.
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > mediaItem.duration) newPosition = mediaItem.duration;
    // Perform the jump via a seek.
    await _player.seek(newPosition);
  }

  /// Broadcasts the current state to all clients.
  Future<void> _broadcastState() async {
    await AudioServiceBackground.setState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      androidCompactActions: [0, 1, 3],
      processingState: _getProcessingState(),
      playing: _player.playing,
      position: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    );
  }

  /// Maps just_audio's processing state into into audio_service's playing
  /// state. If we are in the middle of a skip, we use [_skipState] instead.
  AudioProcessingState _getProcessingState() {
    if (_skipState != null) return _skipState;
    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.stopped;
      case ProcessingState.loading:
        return AudioProcessingState.connecting;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        throw Exception("Invalid state: ${_player.processingState}");
    }
  }

// @override
// Future<void> onAddQueueItem(MediaItem mediaItem) async {
//   _queue.add(mediaItem);
//   AudioServiceBackground.setQueue(_queue);
// }
//
// @override
// Future<void> onRemoveQueueItem(MediaItem mediaItem) async {
//   _queue.remove(mediaItem);
//   AudioServiceBackground.setQueue(_queue);
// }

}
