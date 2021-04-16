import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

class LoopButton extends StatefulWidget {

  @override
  _LoopButtonState createState() => _LoopButtonState();
}

class _LoopButtonState extends State<LoopButton> {

  AudioServiceRepeatMode _repeatMode = AudioServiceRepeatMode.none;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.loop,
        color: _repeatMode == AudioServiceRepeatMode.none
            ? Theme.of(context).colorScheme.onBackground.withOpacity(0.7)
            : Theme.of(context).colorScheme.primary,
      ),
      onPressed:  _repeatMode == AudioServiceRepeatMode.none
          ? () {
        setState(() {
          _repeatMode = AudioServiceRepeatMode.one;
        });
        AudioService.setRepeatMode(_repeatMode);
      }
          : () {
        setState(() {
          _repeatMode = AudioServiceRepeatMode.none;
        });
        AudioService.setRepeatMode(_repeatMode);
      },
    );
  }
}
