import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/models/bloc/player_cubit.dart';

/// An animated expanding playlist widget.
///
/// [showPlaylistAnimationController] controls the expand/collapse animation.
class AudioPlaylistWidget extends StatefulWidget {
  /// Creates an animated playlist widget.
  ///
  /// Use [showPlaylistAnimationController] to control the expand/collapse
  /// animation.
  const AudioPlaylistWidget({
    Key key,
    @required this.currentIndex,
    @required this.showPlaylistAnimationController,
    @required this.queue,
  }) : super(key: key);

  final int currentIndex;

  final List<MediaItem> queue;

  /// An [AnimationController] for showing the playlist list view.
  final AnimationController showPlaylistAnimationController;

  @override
  _AudioPlaylistWidgetState createState() => _AudioPlaylistWidgetState();
}

class _AudioPlaylistWidgetState extends State<AudioPlaylistWidget> {
  ScrollController playlistScrollController;

  final double _listTileHeight = 56.0;

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
    final PlayerCubit activePlayerCubit = context.read<PlayerCubit>();

    final theme = Theme.of(context);

    return SizeTransition(
      sizeFactor: CurvedAnimation(
        curve: Curves.fastOutSlowIn,
        parent: widget.showPlaylistAnimationController,
      ),
      child: SizedBox(
        height: double.infinity,
        child: SizeTransition(
          sizeFactor: CurvedAnimation(
            curve: Curves.fastOutSlowIn,
            parent: widget.showPlaylistAnimationController,
          ),
          child: Material(
            color: theme.colorScheme.background,
            child: ListView.separated(
              key: const PageStorageKey("audioPlayerPlaylist"),
              controller: playlistScrollController,
              padding: EdgeInsets.zero,
              separatorBuilder: (context, index) => Divider(
                color: theme.colorScheme.onBackground,
                indent: 16,
                endIndent: 16,
                height: 0,
              ),
              itemCount: widget.queue.length,
              itemBuilder: (context, index) {
                return ListTile(
                  selected: index == widget.currentIndex,
                  selectedTileColor: theme.colorScheme.primaryVariant,
                  onTap: () {
                    activePlayerCubit.skipToQueueItem(index);
                  },
                  title: Text(
                    widget.queue[index].artist != null
                        ? "${widget.queue[index].title} - ${widget.queue[index].artist}"
                        : widget.queue[index].title,
                    style: theme.textTheme.subtitle1.apply(
                      color: (index == widget.currentIndex)
                          ? theme.colorScheme.onPrimary
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
