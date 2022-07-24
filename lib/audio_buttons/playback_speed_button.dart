import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/models/bloc/player_cubit.dart';

class PlaybackSpeedButton extends StatelessWidget {
  const PlaybackSpeedButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, AudioPlayerState>(
      buildWhen: (prevState, currState) {
        return prevState.speed != currState.speed;
      },
      builder: (context, state) {
        final PlayerCubit activePlayerCubit = context.read<PlayerCubit>();

        return PopupMenuButton<double>(
          onSelected: activePlayerCubit.setSpeed,
          color: Theme.of(context).colorScheme.background,
          itemBuilder: (popupContext) {
            return <PopupMenuEntry<double>>[
              PopupMenuItem<double>(
                value: 0.25,
                child: const Text('0.25x'),
              ),
              PopupMenuItem<double>(
                value: 0.5,
                child: const Text('0.5x'),
              ),
              PopupMenuItem<double>(
                value: 0.75,
                child: const Text('0.75x'),
              ),
              PopupMenuItem<double>(
                value: 1.0,
                child: const Text('1.0x'),
              ),
              PopupMenuItem<double>(
                value: 1.25,
                child: const Text('1.25x'),
              ),
              PopupMenuItem<double>(
                value: 1.50,
                child: const Text('1.5x'),
              ),
            ];
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("${state.speed}x"),
          ),
        );
      },
    );
  }
}
