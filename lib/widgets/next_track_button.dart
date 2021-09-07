import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/models/bloc/player_cubit.dart';

class NextTrackButton extends StatelessWidget {
  const NextTrackButton({
    Key key,
    this.iconSize = 26.0,
  }) : super(key: key);

  /// The size of the icon inside the button.
  ///
  /// This property must not be null. It defaults to 26.0.
  ///
  /// The size given here is passed down to the widget in the [icon] property
  /// via an [IconTheme]. Setting the size here instead of in, for example, the
  /// [Icon.size] property allows the [IconButton] to size the splash area to
  /// fit the [Icon]. If you were to set the size of the [Icon] using
  /// [Icon.size] instead, then the [IconButton] would default to 24.0 and then
  /// the [Icon] itself would likely get clipped.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
        buildWhen: (prevState, currState) {
      return (currState.playerStatus ==
          PlayerStatus.rebuildNextTrackButton);
    }, builder: (context, state) {
      return IconButton(
        icon: const Icon(Icons.skip_next),
        onPressed: checkOnNull(context, state),
        iconSize: iconSize,
      );
    });
  }

  Function checkOnNull(BuildContext context, PlayerState state) {
    final PlayerCubit activePlayerCubit = context.read<PlayerCubit>();

    if (state.currentMediaItem == null ||
        state.queue == null ||
        state.queue.isEmpty) {
      return null;
    }
    if (state.currentMediaItem == state.queue.last) {
      return null;
    }
    return activePlayerCubit.skipToNext;
  }
}
