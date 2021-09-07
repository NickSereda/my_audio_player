import 'package:audio_service/audio_service.dart';

class PlayerRepository {
  // Simple example from assets (Otherwise fetching tracks here from network)
  List<MediaItem> fetchAudioTracks() {
    List<MediaItem> audioList = [
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

    return audioList;
  }
}
