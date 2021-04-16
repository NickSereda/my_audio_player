import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/services/audio_service.dart';
import 'package:my_audio_player/widgets/audio_playlist_widget.dart';
import 'package:my_audio_player/widgets/audio_timeline.dart';
import 'package:my_audio_player/widgets/content_failure_dialog.dart';
import 'package:my_audio_player/widgets/playback_control_buttons.dart';
import 'package:my_audio_player/widgets/title_artist_widget.dart';

import 'models/bloc/audio_player_cubit.dart';

// NOTE: Your entrypoint MUST be a top-level function.
void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class AudioPlayerScreen extends StatefulWidget {
  // final AudioPlayerModel audioPlayerModel;

  AudioPlayerScreen({
    Key key,
    // @required this.audioPlayerModel,
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

  _openPlaylist(List<MediaItem> audioTracks) async {
    List<dynamic> list = [];
    for (int i = 0; i < audioTracks.length; i++) {
      var m = audioTracks[i].toJson();
      list.add(m);
    }

    var params = {"data": list};

    AudioService.connect();

    await AudioService.start(
        backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
        androidNotificationChannelName: 'Audio Service Demo',
        // Enable this if you want the Android service to exit the foreground state on pause.
        //androidStopForegroundOnPause: true,
        androidNotificationColor: 0xFF2196f3,
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidEnableQueue: true,
        params: params);
  }

  @override
  void dispose() {
    AudioService.stop();
    super.dispose();
    _playlistAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocProvider<AudioPlayerCubit>(
        create: (BuildContext context) => AudioPlayerCubit(),
        child: AudioServiceWidget(
          child: BlocListener<AudioPlayerCubit, AudioPlayerState>(
            listener: (context, state) {
              if (state is AudioPlayerLoaded) {
                _openPlaylist(state.audioTracks);
              }
            },
            child: StreamBuilder<bool>(
                stream: AudioService.runningStream,
                builder: (context, snapshot) {
                  // getting tracks
                  context.bloc<AudioPlayerCubit>().getAudioTracks();

                  if (snapshot.connectionState != ConnectionState.active) {
                    // Don't show anything until we've ascertained whether or not the
                    // service is running, since we want to show a different UI in
                    // each case.
                    return SizedBox(
                        child: Center(
                      child: CircularProgressIndicator(),
                    ));
                  }

                  return Column(
                    children: [
                      // Image
                      Expanded(
                        flex: 3,
                        child: Stack(children: [
                          Center(
                            child: Icon(
                              Icons.music_note,
                              color: theme.colorScheme.onBackground
                                  .withOpacity(0.54),
                              size: 220,
                            ),
                          ),
                          AudioPlaylistWidget(
                            showPlaylistAnimationController:
                                _playlistAnimationController,
                          ),
                        ]),
                      ),

                      // Error alert
                      BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                          builder: (context, state) {
                        if (state is AudioPlayerFailure) {
                          return ContentFailureDialog(
                            title: state.title,
                            message: state.message,
                            tryAgainAction: () {
                              context.bloc<AudioPlayerCubit>().getAudioTracks();
                            },
                          );
                        } else {
                          return Container();
                        }
                      }),

                      Expanded(
                        flex: 2,
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                SizedBox(height: 16),
                                TitleArtistWidget(),
                                SizedBox(height: 24),
                                AudioTimeline(),
                                SizedBox(height: 20),
                                PlaybackControlButtons(
                                  showPlaylistAnimationController:
                                      _playlistAnimationController,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}
