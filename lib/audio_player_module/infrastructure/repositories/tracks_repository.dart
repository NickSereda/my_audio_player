import 'package:audio_service/audio_service.dart';

abstract class TracksRepository {
  Future<List<MediaItem>> fetchAudioTracks();
}
