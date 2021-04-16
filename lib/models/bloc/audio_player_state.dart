part of 'audio_player_cubit.dart';

@immutable
abstract class AudioPlayerState extends Equatable {
  const AudioPlayerState();

  @override
  List<Object> get props => [];
}

class AudioPlayerInitial extends AudioPlayerState {
  const AudioPlayerInitial();
}

class AudioPlayerLoading extends AudioPlayerState {
  const AudioPlayerLoading();
}

class AudioPlayerLoaded extends AudioPlayerState {
  final List<MediaItem> audioTracks;

  const AudioPlayerLoaded(this.audioTracks);

  @override
  List<Object> get props => [audioTracks];
}

class AudioPlayerFailure extends AudioPlayerState {
  final String title;
  final String message;

  const AudioPlayerFailure({@required this.title, @required this.message});

  @override
  List<Object> get props => [title, message];
}
