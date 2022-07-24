import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_audio_player/models/bloc/player_cubit.dart';

class PreviousTrackButton extends StatelessWidget {
  const PreviousTrackButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, AudioPlayerState>(
      buildWhen: (prevState, currState) {
        return prevState.currentMediaItem != currState.currentMediaItem ||
            prevState.duration != currState.duration;
      },
      builder: (context, state) {
        final PlayerCubit playerCubit = context.read<PlayerCubit>();
        return IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: playerCubit.skipToPrevious(state),
          iconSize: 26,
        );
      },
    );
  }
}
