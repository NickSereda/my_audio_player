import 'package:audio_service/audio_service.dart';
import 'package:injectable/injectable.dart';
import 'package:my_audio_player/audio_player_module/infrastructure/repositories/tracks_repository.dart';

@Injectable(as: TracksRepository, env: [Environment.prod])
class ProdTracksRepository extends TracksRepository {
  @override
  Future<List<MediaItem>> fetchAudioTracks() {
    // TODO: implement fetchAudioTracks
    throw UnimplementedError();
  }
}
