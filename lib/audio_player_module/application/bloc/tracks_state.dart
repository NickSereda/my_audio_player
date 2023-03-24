part of 'tracks_cubit.dart';

enum TracksStatus { initial, loading, loaded, error, tracksEmpty }

class TracksState extends Equatable {
  final TracksStatus tracksStatus;

  TracksState({
    required this.tracksStatus,
  });

  @override
  List<Object> get props => [tracksStatus];

  TracksState copyWith({
    TracksStatus? tracksStatus,
  }) {
    return TracksState(
      tracksStatus: tracksStatus ?? this.tracksStatus,
    );
  }
}
