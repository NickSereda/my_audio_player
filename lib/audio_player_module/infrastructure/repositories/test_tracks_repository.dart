import 'package:audio_service/audio_service.dart';
import 'package:injectable/injectable.dart';
import 'package:my_audio_player/audio_player_module/infrastructure/repositories/tracks_repository.dart';

@Injectable(as: TracksRepository, env: [Environment.test])
class TestTracksRepository extends TracksRepository {
  static final List<MediaItem> testAudioList = [
    MediaItem(
      // This can be any unique id, but we use the audio URL for convenience.
      id: "asset:///assets/honest-feat-luna-bands.mp3",
      title: "HONEST",
      album: "Rojj",
    ),
    MediaItem(
      // This can be any unique id, but we use the audio URL for convenience.
      id: "asset:///assets/disaster.mp3",
      title: "Disaster",
      album: "Vallhee",
    ),
    MediaItem(
      // This can be any unique id, but we use the audio URL for convenience.
      id: "asset:///assets/sadie.mp3",
      title: "SADIE",
      album: "Welfare",
    ),
    MediaItem(
      // This can be any unique id, but we use the audio URL for convenience.
      id: "asset:///assets/roundabout.mp3",
      title: "ROUNDABOUT",
      album: "The ING",
    ),
    MediaItem(
      // This can be any unique id, but we use the audio URL for convenience.
      id: "asset:///assets/too-many-addictions.mp3",
      title: "TOO MANY ADDICTIONS",
      album: "RZRS",
    ),
  ];

  @override
  Future<List<MediaItem>> fetchAudioTracks() async {
    return testAudioList;
  }
}
