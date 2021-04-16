import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

class ShowPlaylistButton extends StatefulWidget {
  const ShowPlaylistButton({
    Key key,
    @required this.showPlaylistAnimationController,
    this.iconSize = 22.0,
  }) : super(key: key);

  final AnimationController showPlaylistAnimationController;

  final double iconSize;

  @override
  _ShowPlaylistButtonState createState() => _ShowPlaylistButtonState();
}

class _ShowPlaylistButtonState extends State<ShowPlaylistButton> {
  bool buttonEnabled = false;

  void statusListener(AnimationStatus status) {
    if (status == AnimationStatus.forward ||
        status == AnimationStatus.dismissed) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    widget.showPlaylistAnimationController.addStatusListener(statusListener);
  }

  @override
  void dispose() {
    widget.showPlaylistAnimationController.removeStatusListener(statusListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AudioService.queueStream,
      builder: (context, snapshot) {

        if (snapshot.data == null) {
          return Container();
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.format_list_bulleted, size: 22),
            IconButton(
              icon: Container(
                // highlight the button when the playlist is opened
                decoration: ShapeDecoration(
                  color: widget.showPlaylistAnimationController.isDismissed
                      ? Colors.transparent
                      : Theme.of(context).highlightColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: Container(),
              ),
              onPressed:
                  () {
                widget.showPlaylistAnimationController.isCompleted
                    ? widget.showPlaylistAnimationController.reverse()
                    : widget.showPlaylistAnimationController.forward();
              }
              ,
              iconSize: widget.iconSize,
            ),
          ],
        );
      },
    );
  }
}