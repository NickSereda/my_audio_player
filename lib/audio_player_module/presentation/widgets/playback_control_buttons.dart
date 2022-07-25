import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/audio_player_module/application/bloc/player_cubit.dart';
import 'package:my_audio_player/audio_player_module/presentation/audio_buttons/audio_play_pause_button.dart';
import 'package:my_audio_player/audio_player_module/presentation/audio_buttons/next_track_button.dart';
import 'package:my_audio_player/audio_player_module/presentation/audio_buttons/previous_track_button.dart';

class PlaybackControlButtons extends StatelessWidget {
  const PlaybackControlButtons({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PreviousTrackButton(),
        // Play / Pause
        AudioPlayPauseButton(
          onPlay: () async {
            context.read<PlayerCubit>().activateOrPlay();
          },
        ),
        NextTrackButton(),
      ],
    );
  }
}
