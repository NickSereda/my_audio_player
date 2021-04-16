import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

class TitleArtistWidget extends StatelessWidget {
  const TitleArtistWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<MediaItem>(
      stream: AudioService.currentMediaItemStream,
      builder: (context, snapshot) {
        if (snapshot.data == null) return SizedBox();

        final MediaItem mediaItem = snapshot.data;
        final title = mediaItem.title;
        final album = mediaItem.album;

        return Column(
          children: [
            Text(
              album,
              style: theme.textTheme.headline5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: theme.textTheme.subtitle1,
              textAlign: TextAlign.center,
            )
          ],
        );
      },
    );
  }
}
