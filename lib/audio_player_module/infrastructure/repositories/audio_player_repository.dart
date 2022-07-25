import 'package:audio_service/audio_service.dart';

abstract class PlayerRepository {
  Future<List<MediaItem>> fetchAudioTracks();
}
