import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:my_audio_player/audio_player_module/application/bloc/player_cubit.dart';
import 'package:my_audio_player/audio_player_module/application/bloc/tracks_cubit.dart';
import 'package:my_audio_player/audio_player_module/presentation/audio_player_screen.dart';
import 'package:my_audio_player/injection.dart';

GetIt getIt = GetIt.instance;

void main() {
  configureInjection(Environment.test);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PlayerCubit>(
            create: (BuildContext context) => getIt<PlayerCubit>()),
        BlocProvider<TracksCubit>(
            lazy: false,
            create: (BuildContext context) =>
                getIt<TracksCubit>()..getAudioTracks()),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: AudioPlayerScreen(),
      ),
    );
  }
}
