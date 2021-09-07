import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/models/bloc/player_cubit.dart';
import 'package:my_audio_player/widgets/seek_bar.dart';

/// A timeline for audio tracks.
///
/// Consists of a current timestamp and a time left with a [Slider] below them.
class AudioTimeline extends StatelessWidget {
  const AudioTimeline({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlayerCubit activePlayerCubit =
        context.read<PlayerCubit>();

    return BlocBuilder<PlayerCubit, PlayerState>(
        buildWhen: (prevState, currState) {
      return (currState.playerStatus ==
          PlayerStatus.rebuildAudioTimeline);
    }, builder: (context, state) {
      return SeekBar(
        duration: state.duration ?? Duration.zero,
        position: state.position,
        onChangeEnd: (newPosition) {
          activePlayerCubit.seekTo(newPosition);
        },
      );
    });
  }
}
