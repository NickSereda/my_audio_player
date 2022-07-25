part of 'player_cubit.dart';

enum PlayerStatus {
  initial,
  error,
  imageLoading,
  imageError,
  imageChanged,
}

class AudioPlayerState extends Equatable {

  final LoopMode loopMode;

  final List<MediaItem> queue;

  final MediaItem? currentMediaItem;

  final int currentIndex;

  final Duration position;

  final PlayerStatus playerStatus;

  final AudioProcessingState processingState;

  final bool playing;

  final Duration duration;

  final TracksStatus tracksStatus;

  final List<int>? coverImage;

  final double? speed;

  const AudioPlayerState({
    required this.loopMode,
    required this.queue,
    required this.tracksStatus,
    this.currentMediaItem,
    required this.currentIndex,
    required this.position,
    required this.playerStatus,
    required this.processingState,
    required this.playing,
    required this.duration,
    this.coverImage,
    this.speed,
  });

  @override
  List<Object?> get props => [
    loopMode,
    tracksStatus,
    queue,
    currentIndex,
    currentMediaItem,
    position,
    playerStatus,
    processingState,
    playing,
    duration,
    coverImage,
    speed,
  ];

  AudioPlayerState copyWith({
    LoopMode? loopMode,
    TracksStatus? tracksStatus,
    List<MediaItem>? queue,
    MediaItem? currentMediaItem,
    int? currentIndex,
    Duration? position,
    PlayerStatus? playerStatus,
    AudioProcessingState? processingState,
    bool? playing,
    Duration? duration,
    List<int>? coverImage,
    double? speed,
  }) {
    return AudioPlayerState(
      loopMode: loopMode ?? this.loopMode,
      queue: queue ?? this.queue,
      currentMediaItem: currentMediaItem ?? this.currentMediaItem,
      position: position ?? this.position,
      playerStatus: playerStatus ?? this.playerStatus,
      tracksStatus: tracksStatus ?? this.tracksStatus,
      processingState: processingState ?? this.processingState,
      currentIndex: currentIndex ?? this.currentIndex,
      playing: playing ?? this.playing,
      duration: duration ?? this.duration,
      coverImage: coverImage ?? this.coverImage,
      speed: speed ?? this.speed,
    );
  }
}
