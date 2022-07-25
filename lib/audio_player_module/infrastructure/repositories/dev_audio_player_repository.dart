import 'package:audio_service/audio_service.dart';
import 'package:injectable/injectable.dart';
import 'package:my_audio_player/audio_player_module/infrastructure/repositories/audio_player_repository.dart';

@Injectable(as: PlayerRepository, env: [Environment.dev, Environment.prod])
class DevPlayerRepository extends PlayerRepository {
  @override
  Future<List<MediaItem>> fetchAudioTracks() {
    // TODO: implement fetchAudioTracks
    throw UnimplementedError();
  }
}
