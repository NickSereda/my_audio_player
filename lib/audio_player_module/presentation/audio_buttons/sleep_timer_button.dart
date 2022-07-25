import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_audio_player/audio_player_module/application/bloc/player_cubit.dart';

class SleepTimerButton extends StatefulWidget {
  const SleepTimerButton({
    Key? key,
  }) : super(key: key);

  @override
  _SleepTimerButtonState createState() => _SleepTimerButtonState();
}

class _SleepTimerButtonState extends State<SleepTimerButton> {
  Timer _timer = Timer(Duration.zero, () {})..cancel();

  Duration _duration = Duration.zero;

  Future<void> startTimer() async {
    const oneSec = Duration(seconds: 1);
    setState(() {});
    _timer = Timer.periodic(oneSec, (timer) {
      if (_duration.inMicroseconds == 0) {
        timer.cancel();
        final PlayerCubit activePlayerCubit = context.read<PlayerCubit>();
        activePlayerCubit.pausePlayer();
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
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
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

  String _calculateTimerRemaining(Duration duration) {
    final int minutes = duration.inMinutes;
    final int seconds = duration.inSeconds;

    late int totalSeconds;
    if (minutes > 0) {
      totalSeconds = seconds - (minutes * 60);
    } else {
      totalSeconds = seconds;
    }
    return "$minutes min : $totalSeconds sec";
  }

  @override
  Widget build(BuildContext context) {
    final hoursRemainingString = _duration.inHours > 0
        ? "${_duration.inHours} hours : "
        : ""; // don't show hours when there's less than 1 hour left

    final String timerRemaining =
        "$hoursRemainingString${_calculateTimerRemaining(_duration)}";

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
      label: _timer.isActive ? Text(timerRemaining) : const Text("Sleep timer"),
    );
  }
}
