import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:my_audio_player/models/bloc/player_cubit.dart';

class LoopButton extends StatelessWidget {
  const LoopButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, AudioPlayerState>(
      buildWhen: (prevState, currState) {
        return prevState.loopMode != currState.loopMode;
      },
      builder: (context, state) {
        return IconButton(
          icon: Icon(
            Icons.loop,
            color: state.loopMode == LoopMode.off
                ? Theme.of(context).colorScheme.onBackground.withOpacity(0.7)
                : Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => context.read<PlayerCubit>().toggleLoopMode(),
        );
      },
    );
  }
}
