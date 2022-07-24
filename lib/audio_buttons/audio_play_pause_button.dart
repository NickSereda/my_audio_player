import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/models/bloc/player_cubit.dart';

class AudioPlayPauseButton extends StatefulWidget {
  final double size;
  final void Function() onPlay;

  const AudioPlayPauseButton({
    required this.onPlay,
    this.size = 30,
    Key? key,
  }) : super(key: key);

  @override
  _AudioPlayPauseButtonState createState() => _AudioPlayPauseButtonState();
}

class _AudioPlayPauseButtonState extends State<AudioPlayPauseButton>
    with SingleTickerProviderStateMixin {

  late final AnimationController playPauseController;

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
    return BlocBuilder<PlayerCubit, AudioPlayerState>(
      buildWhen: (prevState, currState) {
        return prevState.currentMediaItem != currState.currentMediaItem ||
            prevState.processingState != currState.processingState ||
            prevState.playing != currState.playing;
      },
      builder: (context, state) {
        final PlayerCubit activePlayerCubit = context.read<PlayerCubit>();

        if (state.playing ) {
          playPauseController.forward();
        } else {
          playPauseController.reverse();
        }

        return AnimatedPlayPauseButton(
          activePlayerState: state,
          // isPlayerActive: state.isPlayerActive,
          buttonAnimation: playPauseController.view,
          // loadingIndicatorProgressStream:
          //    widget.audioPlayer.current.map((event) => 1),
          onPressed: state.playing
              ? activePlayerCubit.pausePlayer
              : widget.onPlay,
          //  processingState: state.processingState,
        );
      },
    );
  }
}

/// An animated play pause button with loading circle around the button.
class AnimatedPlayPauseButton extends StatelessWidget {
  const AnimatedPlayPauseButton({
    Key? key,
    required this.buttonAnimation,
    //  required this.isPlayerActive,

    //required this.processingState,
    required this.activePlayerState,
    this.onPressed,
    this.size = 30,
  }) : super(key: key);

  final Animation<double> buttonAnimation;

  /// The callback that is called when the button is tapped or otherwise activated.
  ///
  /// If this is set to null, the button will be disabled.
  final VoidCallback? onPressed;

  final double size;

  final AudioPlayerState activePlayerState;

  @override
  Widget build(BuildContext context) {
    double? indicatorValue = 1.0;

    // Handle Stop
    if (activePlayerState.processingState == AudioProcessingState.idle) {
      indicatorValue = null;
    }

    if (activePlayerState.processingState == AudioProcessingState.loading ||
        activePlayerState.processingState == AudioProcessingState.buffering) {
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
            value: indicatorValue,
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
