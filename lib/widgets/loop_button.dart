import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/models/bloc/player_cubit.dart';

class LoopButton extends StatefulWidget {
  const LoopButton({Key key}) : super(key: key);

  @override
  _LoopButtonState createState() => _LoopButtonState();
}

class _LoopButtonState extends State<LoopButton> {
  AudioServiceRepeatMode _repeatMode = AudioServiceRepeatMode.none;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
        buildWhen: (prevState, currState) {
      return (currState.playerStatus == PlayerStatus.rebuildLoopButton);
    }, builder: (context, state) {
      return IconButton(
        icon: Icon(
          Icons.loop,
          color: _repeatMode == AudioServiceRepeatMode.none
              ? Theme.of(context).colorScheme.onBackground.withOpacity(0.7)
              : Theme.of(context).colorScheme.primary,
        ),
        onPressed: _repeatMode == AudioServiceRepeatMode.none
            ? () {
                setState(() {
                  _repeatMode = AudioServiceRepeatMode.one;
                });
                context.read<PlayerCubit>().setRepeatMode(_repeatMode);
                // AudioService.setRepeatMode(_repeatMode);
              }
            : () {
                setState(() {
                  _repeatMode = AudioServiceRepeatMode.none;
                });
                context.read<PlayerCubit>().setRepeatMode(_repeatMode);
              },
      );
    });
  }
}
