import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:my_audio_player/models/bloc/player_cubit.dart';

class AudioPlayPauseButton extends StatefulWidget {
  final double size;
  final Function onPlay;

  const AudioPlayPauseButton({
    this.onPlay,
    this.size = 30,

    Key key,
  }) : super(key: key);

  @override
  _AudioPlayPauseButtonState createState() => _AudioPlayPauseButtonState();
}

class _AudioPlayPauseButtonState extends State<AudioPlayPauseButton>
    with SingleTickerProviderStateMixin {
  /// Animation controller for the animated play-pause button.
  AnimationController playPauseController;

  @override
  void initState() {
    super.initState();
    playPauseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    playPauseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PlayerCubit activePlayerCubit =
    context.read<PlayerCubit>();

    return BlocBuilder<PlayerCubit, PlayerState>(
        buildWhen: (prevState, currState) {
          return (currState.playerStatus ==
              PlayerStatus.rebuildPlayPauseButton);
        }, builder: (context, state) {

      if (state.playing) {
        playPauseController.forward();
      } else {
        playPauseController.reverse();
      }

      return AnimatedPlayPauseButton(
        buttonAnimation: playPauseController.view,
        // loadingIndicatorProgressStream:
        //    widget.audioPlayer.current.map((event) => 1),
        onPressed: state.playing ? activePlayerCubit.pausePlayer : widget.onPlay,
        processingState: state.playbackState?.processingState,
      );
    });
  }
}

/// An animated play pause button with loading circle around the button.
class AnimatedPlayPauseButton extends StatelessWidget {
  const AnimatedPlayPauseButton({
    Key key,
    @required this.buttonAnimation,

    @required this.processingState,
    this.onPressed,
    this.size = 30,
  }) : super(key: key);

  final Animation<double> buttonAnimation;

  /// The callback that is called when the button is tapped or otherwise activated.
  ///
  /// If this is set to null, the button will be disabled.
  final VoidCallback onPressed;

  final double size;

  final AudioProcessingState processingState;

  @override
  Widget build(BuildContext context) {
    double indicatorValue = 1.0;

    if (processingState != null) {
      if (processingState == AudioProcessingState.loading) {
        indicatorValue = null;
      }
    } else {
      indicatorValue = null;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // circular progress indicator around the button
        SizedBox.fromSize(
          size: Size.fromRadius(size - 5),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value:  indicatorValue,

          ),
        ),
        IconButton(
          icon: AnimatedIcon(
            icon: AnimatedIcons.play_pause,
            progress: buttonAnimation,
          ),
          onPressed: onPressed,
          iconSize: size,
        ),
      ],
    );
  }
}
