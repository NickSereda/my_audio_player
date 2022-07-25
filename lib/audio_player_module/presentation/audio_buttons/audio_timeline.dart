import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/audio_player_module/application/bloc/player_cubit.dart';
import 'package:my_audio_player/audio_player_module/presentation/audio_buttons/seek_bar.dart';

class AudioTimeline extends StatelessWidget {
  const AudioTimeline({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, AudioPlayerState>(
      buildWhen: (prevState, currState) {
        return prevState.currentMediaItem != currState.currentMediaItem ||
            prevState.duration != currState.duration ||
            prevState.position != currState.position;
      },
      builder: (context, state) {
        final PlayerCubit activePlayerCubit =
            context.read<PlayerCubit>();

        return SeekBar(
          duration: state.duration,
          position: state.position,
          onChangeEnd: (newPosition) {
            activePlayerCubit.seekTo(newPosition);
          },
        );
      },
    );
  }
}
