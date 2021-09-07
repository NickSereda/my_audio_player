import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/models/bloc/player_cubit.dart';
import 'package:my_audio_player/models/bloc/tracks_cubit.dart';
import 'package:my_audio_player/widgets/audio_play_pause_button.dart';
import 'package:my_audio_player/widgets/loop_button.dart';
import 'package:my_audio_player/widgets/next_track_button.dart';
import 'package:my_audio_player/widgets/previous_track_button.dart';
import 'package:my_audio_player/widgets/show_playlist_button.dart';

/// A row of buttons that control playback of an audio track.
class PlaybackControlButtons extends StatelessWidget {
  const PlaybackControlButtons({
    Key key,
    @required this.showPlaylistAnimationController,
  }) : super(key: key);

  /// An [AnimationController] for showing the playlist list view.
  final AnimationController showPlaylistAnimationController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LoopButton(),
        PreviousTrackButton(),
        // Play / Pause
        BlocBuilder<PlayerCubit, PlayerState>(
          buildWhen: (prevState, currState) {
            return currState.playerStatus ==
                PlayerStatus.rebuildPlaybackControlButtons;
          },
          builder: (context, state) {
            return AudioPlayPauseButton(
              onPlay: () async {

                if (state.playbackState != null) {
                  if (state.playbackState.processingState ==
                      AudioProcessingState.idle) {
                    await BlocProvider.of<TracksCubit>(context)
                        .getAudioTracks()
                        .then(
                          (tracks) => Future.delayed(
                        const Duration(milliseconds: 500),
                            () {
                          context.read<PlayerCubit>().activatePlayer(
                            tracks: tracks,
                          );
                        },
                      ),
                    );
                  } else {
                    context.read<PlayerCubit>().play();
                  }
                }
              },
            );
          },
        ),
        NextTrackButton(),
        ShowPlaylistButton(
          showPlaylistAnimationController: showPlaylistAnimationController,
        ),
      ],
    );
  }
}
