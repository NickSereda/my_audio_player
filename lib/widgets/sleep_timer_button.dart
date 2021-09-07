import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/models/bloc/player_cubit.dart';

/// A sleep timer button for audio player.
///
/// When pressed, shows a Cupertino style timer picker.
///
/// When active, shows timer countdown.
///
/// Uses pausePlayer method in [PlayerCubit] to pause currently playing audio.
class SleepTimerButton extends StatefulWidget {
  /// Creates a sleep timer button for audio player.
  ///
  /// When pressed, shows a Cupertino style timer picker.
  ///
  /// When active, shows timer countdown.
  ///
  /// Uses pausePlayer method in [PlayerCubit] to pause currently playing audio.
  const SleepTimerButton({Key key}) : super(key: key);

  @override
  _SleepTimerButtonState createState() => _SleepTimerButtonState();
}

class _SleepTimerButtonState extends State<SleepTimerButton> {
  Timer _timer = Timer(Duration.zero, () {})
    ..cancel(); // TODO: maybe there should be one global timer? to avoid memory leak

  Duration _duration = const Duration();

  Future<void> startTimer() async {
    const oneSec = Duration(seconds: 1);
    setState(() {});
    _timer = Timer.periodic(oneSec, (timer) {
      if (_duration.inMicroseconds == 0) {
        timer.cancel();
        context.read<PlayerCubit>().pausePlayer();
        // AudioService.pause();
        setState(() {});
      } else {
        setState(() {
          _duration = _duration - oneSec;
        });
      }
    });
  }

  void _selectTime() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                CupertinoTimerPicker(
                  onTimerDurationChanged: (value) {
                    _duration = value;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        startTimer();
                        Navigator.of(context).pop();
                      },
                      child: const Text("Ok"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hoursRemainingString = _duration.inHours > 0
        ? "${_duration.inHours} hours : "
        : ""; // don't show hours when there's less than 1 hour left
    final String timerRemaining =
        "$hoursRemainingString${_duration.inMinutes} min : ${_duration.inSeconds} sec";

    return BlocBuilder<PlayerCubit, PlayerState>(
        buildWhen: (prevState, currState) {
      return (currState.playerStatus ==
          PlayerStatus.rebuildSleepTimerButton);
    }, builder: (context, state) {
      return OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
          side: BorderSide(
            width: 0.3,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
          ),
        ),
        onPressed: _timer.isActive
            ? () {
                setState(() {
                  _timer.cancel();
                });
              }
            : _selectTime,
        icon: _timer.isActive
            ? const Icon(Icons.cancel)
            : const Icon(Icons.nightlight_round),
        label:
            _timer.isActive ? Text(timerRemaining) : const Text("Sleep timer"),
      );
    });
  }
}
