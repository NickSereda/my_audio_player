part of 'player_cubit.dart';

enum PlayerStatus {
  initial,
  error,
  imageLoading,
  imageError,
  imageChanged,
}

@freezed
class AudioPlayerState with _$AudioPlayerState {
  const factory AudioPlayerState({
    required LoopMode loopMode,
    @Default(<MediaItem>[]) List<MediaItem> queue,
    MediaItem? currentMediaItem,
    required int currentIndex,
    required Duration position,
    required PlayerStatus playerStatus,
    required AudioProcessingState processingState,
    required bool playing,
    required Duration duration,
    double? speed,
  }) = _AudioPlayerState;

}
