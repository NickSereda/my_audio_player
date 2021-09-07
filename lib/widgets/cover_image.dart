import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/models/bloc/player_cubit.dart';
import 'package:my_audio_player/widgets/album_cover_image.dart';

class CoverImage extends StatelessWidget {
  const CoverImage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      buildWhen: (previousState, state) {
        return (previousState.currentMediaItem != state.currentMediaItem ||
            previousState.coverImage != state.coverImage ||
            (state.playerStatus == PlayerStatus.imageChanged ||
                state.playerStatus == PlayerStatus.imageLoading ||
                state.playerStatus == PlayerStatus.imageError));
      },
      builder: (BuildContext context, state) {
        if (state.playerStatus == PlayerStatus.imageLoading) {
          return Center(
            child: Container(
              color: Theme.of(context).colorScheme.background,
              height: 100,
              width: 100,
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.playerStatus == PlayerStatus.imageChanged) {
          return Center(
            child: Container(
              height: MediaQuery.of(context).size.width / 1.3,
              width: MediaQuery.of(context).size.width / 1.3,
              child: AlbumCoverImage(
                image: MemoryImage(state.coverImage),
              ),
            ),
          );
        }

        return Container();
      },
    );
  }
}
