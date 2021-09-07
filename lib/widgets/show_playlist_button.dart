import 'package:flutter/material.dart';

/// A button which opens the audio tracks playlist.
///
/// The button stays highlighted when the playlist is opened.
class ShowPlaylistButton extends StatefulWidget {
  const ShowPlaylistButton({
    Key key,
    @required this.showPlaylistAnimationController,
    this.iconSize = 22.0,
  }) : super(key: key);

  /// An [AnimationController] for showing the playlist list view.
  final AnimationController showPlaylistAnimationController;


  /// The size of the icon inside the button.
  ///
  /// This property must not be null. It defaults to 22.0.
  ///
  /// The size given here is passed down to the widget in the [icon] property
  /// via an [IconTheme]. Setting the size here instead of in, for example, the
  /// [Icon.size] property allows the [IconButton] to size the splash area to
  /// fit the [Icon]. If you were to set the size of the [Icon] using
  /// [Icon.size] instead, then the [IconButton] would default to 24.0 and then
  /// the [Icon] itself would likely get clipped.
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
              onPressed: () {
                      widget.showPlaylistAnimationController.isCompleted
                          ? widget.showPlaylistAnimationController.reverse()
                          : widget.showPlaylistAnimationController.forward();
                    },
              iconSize: widget.iconSize,
            ),
          ],
        );
  }
}
