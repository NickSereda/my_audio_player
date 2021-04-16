import 'package:flutter/material.dart';
import 'package:my_audio_player/widgets/seek_bar.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_service/audio_service.dart';

class MediaState {
  final MediaItem mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}

class AudioTimeline extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<MediaState>(
      stream: Rx.combineLatest2<MediaItem, Duration, MediaState>(
          AudioService.currentMediaItemStream,
          AudioService.positionStream,
              (mediaItem, position) => MediaState(mediaItem, position)),
      builder: (context, snapshot) {
        final mediaState = snapshot.data;
        return SeekBar(
          duration: mediaState?.mediaItem?.duration ?? Duration.zero,
          position: mediaState?.position ?? Duration.zero,
          onChangeEnd: (newPosition) {
            AudioService.seekTo(newPosition);
          },
        );
      },
    );
  }
}

