import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/models/bloc/audio_player_cubit.dart';
import 'package:my_audio_player/widgets/loop_button.dart';
import 'package:my_audio_player/widgets/set_speed_button.dart';
import 'package:my_audio_player/widgets/show_playlist_button.dart';
import 'package:my_audio_player/widgets/shuffle_button.dart';
import 'package:my_audio_player/widgets/sleep_timer_button.dart';
import 'package:rxdart/rxdart.dart';

class QueueState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;
  final bool playing;

  QueueState(this.queue, this.mediaItem, this.playing);
}

class PlaybackControlButtons extends StatelessWidget {
  const PlaybackControlButtons({
    Key key,
    @required this.showPlaylistAnimationController,
  }) : super(key: key);

  final AnimationController showPlaylistAnimationController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QueueState>(
        stream: Rx.combineLatest3<List<MediaItem>, MediaItem, bool, QueueState>(
            AudioService.queueStream,
            AudioService.currentMediaItemStream,
            AudioService.playbackStateStream
                .map((state) => state.playing)
                .distinct(),
            (queue, mediaItem, playing) =>
                QueueState(queue, mediaItem, playing)),
        builder: (context, snapshot) {
          final queueState = snapshot.data;

          final mediaItem = queueState?.mediaItem;

          final queue = queueState?.queue;

          final playing = queueState?.playing ?? false;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LoopButton(),
                    IconButton(
                        icon: Icon(Icons.skip_previous),
                        iconSize: 64.0,
                        onPressed: mediaItem == null
                            ? null
                            : mediaItem == queue.first
                                ? null
                                : AudioService.skipToPrevious),

                    // Play / Pause
                    playing != true
                        ? IconButton(
                            icon: Icon(Icons.play_arrow),
                            iconSize: 64.0,
                            onPressed: () async {
                              if (AudioService.playbackState.processingState ==
                                  AudioProcessingState.none) {
                                await BlocProvider.of<AudioPlayerCubit>(context)
                                    .getAudioTracks();
                              } else {
                                AudioService.play();
                              }
                            })
                        : IconButton(
                            icon: Icon(Icons.pause),
                            iconSize: 64.0,
                            onPressed: AudioService.pause,
                          ),
                    IconButton(
                      icon: Icon(Icons.skip_next),
                      iconSize: 64.0,
                      onPressed: mediaItem == null
                          ? null
                          : mediaItem == queue.last
                              ? null
                              : AudioService.skipToNext,
                    ),
                    ShowPlaylistButton(
                      showPlaylistAnimationController:
                          showPlaylistAnimationController,
                    ),
                  ]),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SetSpeedButton(),
                  SleepTimerButton(),
                  ShuffleButton(),
                ],
              ),
            ],
          );
        });
  }
}
