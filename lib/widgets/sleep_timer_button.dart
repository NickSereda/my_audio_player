import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SleepTimerButton extends StatefulWidget {

  @override
  _SleepTimerButtonState createState() => _SleepTimerButtonState();
}

class _SleepTimerButtonState extends State<SleepTimerButton> {
  Timer _timer;

  bool _isTimerRunning = false;

  int _durationInHours = 0;
  int _durationInMinutes = 0;
  int _durationInSeconds = 0;

  Duration _duration;

  Future<void> startTimer() async {
    int totalSeconds = _duration.inSeconds;
    const oneSec = Duration(seconds: 1);

    setState(() {
      _durationInHours = (totalSeconds / (60 * 60)).truncate();

      _durationInMinutes = (totalSeconds / 60).truncate().remainder(60);

      _durationInSeconds = totalSeconds.remainder(60);
    });

    setState(() {
      _isTimerRunning = true;
    });
    _timer = Timer.periodic(oneSec, (timer) {
      if (totalSeconds == 0) {
        // print("DONE");
        timer.cancel();
        AudioService.pause();
        setState(() {
          _isTimerRunning = false;
        });
      } else {
        totalSeconds--;
        setState(() {
          _durationInHours = (totalSeconds / (60 * 60)).truncate();
          _durationInMinutes = (totalSeconds / 60).truncate().remainder(60);
          _durationInSeconds = totalSeconds.remainder(60);
        });
        // print("$totalSeconds");
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
    final hoursRemainingString = _durationInHours > 0
        ? "$_durationInHours hours : "
        : ""; // don't show hours when there's less than 1 hour left
    final String timerRemaining =
        "$hoursRemainingString$_durationInMinutes min : $_durationInSeconds sec";

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
      onPressed: _isTimerRunning
          ? () {
        _timer.cancel();
        setState(() {
          _isTimerRunning = false;
        });
      }
          : _selectTime,
      icon: _isTimerRunning
          ? const Icon(Icons.cancel)
          : const Icon(Icons.nightlight_round),
      label: _isTimerRunning ? Text(timerRemaining) : const Text("Sleep timer"),
    );
  }
}
