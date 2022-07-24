import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/audio_player_screen.dart';
import 'package:my_audio_player/models/audio_player_repository.dart';
import 'package:my_audio_player/models/bloc/player_cubit.dart';
import 'package:my_audio_player/models/bloc/tracks_cubit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PlayerCubit>(
            create: (BuildContext context) =>
                PlayerCubit()),
        BlocProvider<TracksCubit>(
            lazy: false,
            create: (BuildContext context) =>
            TracksCubit(PlayerRepository(), context.read<PlayerCubit>())..getAudioTracks()),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: AudioPlayerScreen(),
      ),
    );
  }
}
