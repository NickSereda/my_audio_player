import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/models/bloc/player_cubit.dart';

class TitleArtistWidget extends StatelessWidget {
  const TitleArtistWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<PlayerCubit, PlayerState>(
        buildWhen: (prevState, currState) {
      return (currState.playerStatus ==
          PlayerStatus.rebuildTitleArtistWidget);
    }, builder: (context, state) {
      return Column(
        children: [
          Text(
            state.currentMediaItem?.title ?? "",
            style: theme.textTheme.headline5,
            textAlign: TextAlign.center,
          ),
          if (state.currentMediaItem?.artist != null) ...[
            const SizedBox(height: 5),
            Text(
              state.currentMediaItem?.artist ?? "",
              style: theme.textTheme.subtitle1,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    });
  }
}
