import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

class ShuffleButton extends StatefulWidget {
  @override
  _ShuffleButtonState createState() => _ShuffleButtonState();
}

class _ShuffleButtonState extends State<ShuffleButton> {
  bool _isShuffled = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.shuffle,
        color: _isShuffled
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
      ),
      onPressed: () {
        AudioService.customAction("shuffle", _isShuffled);
        setState(() {
          _isShuffled = !_isShuffled;
        });
      },
    );
  }
}
