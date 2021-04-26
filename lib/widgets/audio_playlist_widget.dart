import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class QueueMediaState {
  final List<MediaItem> queue;
  final MediaItem item;

  QueueMediaState(this.queue, this.item);
}

class AudioPlaylistWidget extends StatefulWidget {
  const AudioPlaylistWidget({
    Key key,
    @required this.showPlaylistAnimationController,
  }) : super(key: key);

  final AnimationController showPlaylistAnimationController;

  @override
  _AudioPlaylistWidgetState createState() => _AudioPlaylistWidgetState();
}

const double _listTileHeight = 56.0;

class _AudioPlaylistWidgetState extends State<AudioPlaylistWidget> {
  ScrollController playlistScrollController;

  int previousAudioIndex;

  @override
  void initState() {
    super.initState();
    playlistScrollController =
        ScrollController(initialScrollOffset: _listTileHeight);
  }

  @override
  void dispose() {
    playlistScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  final theme = Theme.of(context);

    return SizeTransition(
      sizeFactor: CurvedAnimation(
        curve: Curves.fastOutSlowIn,
        parent: widget.showPlaylistAnimationController,
      ),
      child: Container(
        height: 500.0,
        //queue stream + current audio stream
        child: StreamBuilder(
          stream:
              Rx.combineLatest2<List<MediaItem>, MediaItem, QueueMediaState>(
                  AudioService.queueStream,
                  AudioService.currentMediaItemStream,
                  (queue, item) => QueueMediaState(queue, item)),
          builder: (context, snapshot) {
            final data = snapshot.data;

            final List<MediaItem> sequence = data?.queue ?? [];

            final MediaItem currentMediaItem = data?.item;


            int currentIndex = 0;

            if (data != null && currentMediaItem != null) {
              currentIndex = sequence
                  .indexWhere((element) => element.id == currentMediaItem.id);
            }

            return ListView(
              children: [
                for (var i = 0; i < sequence.length; i++)
                  // Playlist List Tile
                  Material(
                    key: ValueKey(sequence[i]),
                    color: i == currentIndex ? Colors.grey.shade300 : null,
                    child: ListTile(
                      title: Text(sequence[i].title),
                      onTap: () {
                        AudioService.customAction("seekToTrack", i);
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
