import 'package:audio_service/audio_service.dart';
import 'package:injectable/injectable.dart';
import 'package:my_audio_player/audio_player_module/infrastructure/repositories/tracks_repository.dart';
import 'package:rxdart/rxdart.dart';

@lazySingleton
class TracksService {
  TracksService(this._repository);

  final TracksRepository _repository;

  final BehaviorSubject<List<MediaItem>?> _tracksController =
      BehaviorSubject<List<MediaItem>?>();

  Stream<List<MediaItem>?> get tracksStream => _tracksController.stream;

  Future<void> getTracks() async {
    final tracks = await _repository.fetchAudioTracks();
    _tracksController.add(tracks);
  }

  @disposeMethod
  Future<void> close() async {
    await _tracksController.close();
  }
}
