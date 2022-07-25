import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/audio_player_module/application/bloc/player_cubit.dart';

class NextTrackButton extends StatelessWidget {
  const NextTrackButton({
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
        final PlayerCubit activePlayerCubit = context.read<PlayerCubit>();

        return IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: activePlayerCubit.skipToNext(state),
          iconSize: 26,
        );
      },
    );
  }
}
