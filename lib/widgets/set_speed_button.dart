import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

class SetSpeedButton extends StatelessWidget {
  void _showSliderDialog({
    @required BuildContext context,
    @required String title,
    @required int divisions,
    @required double min,
    @required double max,
    String valueSuffix = '',
    @required Stream<double> stream,
    @required ValueChanged<double> onChanged,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, textAlign: TextAlign.center),
        content: StreamBuilder<double>(
          stream: stream,
          builder: (context, snapshot) => Container(
            height: 100.0,
            child: Column(
              children: [
                Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                    style: TextStyle(
                        fontFamily: 'Fixed',
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0)),
                Slider(
                  divisions: divisions,
                  min: min,
                  max: max,
                  value: snapshot.data ?? 1.0,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
        stream: AudioService.playbackStateStream
            .map((event) => event.speed)
            .distinct(),
        builder: (context, snapshot) {
          //final double speed = snapshot.data;
          if (snapshot.data == null) {
            return SizedBox();
          }

          return IconButton(
            icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              _showSliderDialog(
                context: context,
                title: "Adjust speed",
                divisions: 10,
                min: 0.5,
                max: 1.5,
                stream: AudioService.playbackStateStream
                    .map((event) => event.speed)
                    .distinct(),
                onChanged: AudioService.setSpeed,
              );
            },
          );
        });
  }
}
