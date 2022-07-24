import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/audio_buttons/audio_timeline.dart';
import 'package:my_audio_player/audio_buttons/loop_button.dart';
import 'package:my_audio_player/audio_buttons/playback_speed_button.dart';
import 'package:my_audio_player/audio_buttons/sleep_timer_button.dart';
import 'package:my_audio_player/audio_buttons/title_artist_widget.dart';
import 'package:my_audio_player/models/bloc/tracks_cubit.dart';
import 'package:my_audio_player/widgets/playback_control_buttons.dart';

import 'models/bloc/player_cubit.dart';

class AudioPlayerScreen extends StatefulWidget {
  AudioPlayerScreen({
    Key? key,
  }) : super(key: key);

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _playlistAnimationController;

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
    return Scaffold(
      body: BlocConsumer<PlayerCubit, AudioPlayerState>(
        listener: (prevState, currState) {
          if (currState.playerStatus == PlayerStatus.error) {
            // getErrorMessageSnackBar(context);
          }
        },
        buildWhen: (prevState, currState) {
          return (prevState.playerStatus != currState.playerStatus);
        },
        builder: (context, playerState) {
          return Column(
            children: [
              // Image
              Flexible(
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Container(
                          height: MediaQuery.of(context).size.width / 1.3,
                          child: const Icon(Icons.audiotrack, size: 60),
                        ),
                      ),
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
                child: PlaybackControlButtons(),
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
                    LoopButton(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
