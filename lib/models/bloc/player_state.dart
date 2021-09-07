part of 'player_cubit.dart';

/// Current status of [PlayerCubit].
enum PlayerStatus {

  initial,
  error,

  // Cover image statuses
  imageLoading,
  imageError,
  imageChanged,

  // Rebuild statuses
  rebuildAudioPlayerWidget,
  rebuildPlayPauseButton,
  rebuildAudioTimeline,
  rebuildPlaybackSpeedButton,
  rebuildLoopButton,
  rebuildNextTrackButton,
  rebuildPreviousTrackButton,
  rebuildTitleArtistWidget,
  rebuildSleepTimerButton,
  rebuildPlaybackControlButtons,

}

/// Current status of [queue].
enum TracksStatus {
  initial,
  tracksLoading,
  tracksLoaded,
  tracksEmpty,
  tracksError,
}



class PlayerState extends Equatable {

  final List<MediaItem> queue;

  final MediaItem currentMediaItem;

  final int currentIndex;

  final Duration position;

  final PlayerStatus playerStatus;

  final PlaybackState playbackState;

  /// Flag that indicates if player is playing.
  final bool playing;

  /// Duration of the current track.
  final Duration duration;

  final List<int> coverImage;

  const PlayerState({
    this.queue,
    this.currentMediaItem,
    this.currentIndex,
    this.position,
    this.playerStatus,
    this.playbackState,
    this.playing,
    this.duration,
    this.coverImage,
  });

  @override
  List<Object> get props => [
    queue,
    currentIndex,
    currentMediaItem,
    position,
    playerStatus,
    playbackState,
    playing,
    duration,
    coverImage,
  ];

  PlayerState copyWith({
    List<MediaItem> queue,
    MediaItem currentMediaItem,
    int currentIndex,
    Duration position,
    PlayerStatus activePlayerStatus,
    PlaybackState playbackState,
    bool isPlayerActive,
    bool playing,
    Duration duration,
    List<int> coverImage,
  }) {
    return PlayerState(
      queue: queue ?? this.queue,
      currentMediaItem: currentMediaItem ?? this.currentMediaItem,
      position: position ?? this.position,
      playerStatus: activePlayerStatus ?? this.playerStatus,
      playbackState: playbackState ?? this.playbackState,
      currentIndex: currentIndex ?? this.currentIndex,
      playing: playing ?? this.playing,
      duration: duration ?? this.duration,
      coverImage: coverImage ?? this.coverImage,
    );
  }
}
