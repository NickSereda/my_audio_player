part of 'tracks_cubit.dart';

@immutable
abstract class TracksState extends Equatable {
  const TracksState();

  @override
  List<Object> get props => [];
}

class TracksInitial extends TracksState {
  const TracksInitial();
}

class TracksLoading extends TracksState {
  const TracksLoading();
}

class TracksLoaded extends TracksState {
  final List<MediaItem> audioTracks;

  const TracksLoaded(this.audioTracks);

  @override
  List<Object> get props => [audioTracks];
}


class TracksFailure extends TracksState {
  final String title;
  final String message;

  const TracksFailure({@required this.title, @required this.message});

  @override
  List<Object> get props => [title, message];
}
