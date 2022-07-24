part of 'tracks_cubit.dart';

enum TracksStatus { initial, loading, loaded, error, tracksEmpty }

class TracksState extends Equatable {
  final List<MediaItem> audioTracks;
  final TracksStatus tracksStatus;

  TracksState({
    required this.tracksStatus,
    required this.audioTracks,
  });

  @override
  List<Object> get props => [tracksStatus, audioTracks];

  TracksState copyWith({
    TracksStatus? tracksStatus,
    List<MediaItem>? audioTracks,
  }) {
    return TracksState(
      tracksStatus: tracksStatus ?? this.tracksStatus,
      audioTracks: audioTracks ?? this.audioTracks,
    );
  }
}
