import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/models/bloc/player_cubit.dart';

class PlaybackSpeedButton extends StatelessWidget {
  const PlaybackSpeedButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      buildWhen: (prevState, currState) {
        return (currState.playerStatus ==
            PlayerStatus.rebuildPlaybackSpeedButton);
      },
      builder: (context, state) {
        final PlayerCubit activePlayerCubit = context.read<PlayerCubit>();

        return PopupMenuButton<double>(
          tooltip: "Change playback speed",
          onSelected: activePlayerCubit.setSpeed,
          color: Theme.of(context).colorScheme.background,
          itemBuilder: (popupContext) {
            return <PopupMenuEntry<double>>[
              PopupMenuItem<double>(
                value: 0.25,
                child: Text('0.25x'),
              ),
              PopupMenuItem<double>(
                value: 0.5,
                child: Text('0.5x'),
              ),
              PopupMenuItem<double>(
                value: 0.75,
                child: Text('0.75x'),
              ),
              PopupMenuItem<double>(
                value: 1.0,
                child: Text('1.0x'),
              ),
              PopupMenuItem<double>(
                value: 1.25,
                child: Text('1.25x'),
              ),
              PopupMenuItem<double>(
                value: 1.50,
                child: Text('1.5x'),
              ),
              PopupMenuItem<double>(
                value: 1.75,
                child: Text('1.75x'),
              ),
              PopupMenuItem<double>(
                value: 2.0,
                child: Text('2x'),
              ),
            ];
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<double>(
                stream: activePlayerCubit.getSpeedStream(),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return const Text("1.0x");
                  }
                  return Text("${snapshot.data?.toString()}x");
                }),
          ),
        );
      },
    );
  }
}
