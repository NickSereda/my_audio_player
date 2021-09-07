import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/models/audio_player_repository.dart';
import 'package:my_audio_player/widgets/audio_playlist_widget.dart';
import 'package:my_audio_player/widgets/audio_timeline.dart';
import 'package:my_audio_player/widgets/content_failure_dialog.dart';
import 'package:my_audio_player/widgets/cover_image.dart';
import 'package:my_audio_player/widgets/error_message_snack_bar.dart';
import 'package:my_audio_player/widgets/playback_control_buttons.dart';
import 'package:my_audio_player/widgets/playback_speed_button.dart';
import 'package:my_audio_player/widgets/sleep_timer_button.dart';
import 'package:my_audio_player/widgets/title_artist_widget.dart';

import 'models/bloc/player_cubit.dart';
import 'models/bloc/tracks_cubit.dart';

class AudioPlayerScreen extends StatefulWidget {
  AudioPlayerScreen({
    Key key,
  }) : super(key: key);

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _playlistAnimationController;

  @override
  void initState() {
    super.initState();

    _playlistAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _playlistAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PlayerCubit>(
            create: (BuildContext context) => PlayerCubit()),
        BlocProvider<TracksCubit>(
            create: (BuildContext context) => TracksCubit(PlayerRepository())),
      ],
      child: BlocBuilder<TracksCubit, TracksState>(
        builder: (context, state) {
          if (state is TracksLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is TracksLoaded) {
            return BlocConsumer<PlayerCubit, PlayerState>(
                listener: (prevState, currState) {
              if (currState.playerStatus == PlayerStatus.error) {
                getErrorMessageSnackBar(context);
              }
            }, buildWhen: (prevState, currState) {
              return (currState.playerStatus ==
                  PlayerStatus.rebuildAudioPlayerWidget);
            }, builder: (context, activePlayerState) {
              final theme = Theme.of(context);

              return Column(
                children: [
                  // Image
                  Flexible(
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.music_note,
                            color: theme.colorScheme.onBackground
                                .withOpacity(0.54),
                            size: 100,
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(48.0),
                            child: Container(
                              height: MediaQuery.of(context).size.width / 1.3,
                              child: CoverImage(),
                            ),
                          ),
                        ),
                        AudioPlaylistWidget(
                          queue: activePlayerState.queue,
                          currentIndex: activePlayerState.currentIndex,
                          showPlaylistAnimationController:
                              _playlistAnimationController,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  TitleArtistWidget(),
                  SizedBox(height: 24),

                  AudioTimeline(),
                  SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                    child: PlaybackControlButtons(
                      showPlaylistAnimationController:
                          _playlistAnimationController,
                    ),
                  ),
                  SizedBox(height: 25.0),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PlaybackSpeedButton(),
                        SleepTimerButton(),
                      ],
                    ),
                  ),
                ],
              );
            });
          }

          if (state is TracksFailure) {
            return Center(
              child: ContentFailureDialog(
                  title: state.title,
                  tryAgainAction: () =>
                      context.read<TracksCubit>().getAudioTracks()),
            );
          }

          return Container();
        },
      ),
    );
  }
}
