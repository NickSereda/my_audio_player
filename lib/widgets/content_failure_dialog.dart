import 'package:flutter/material.dart';

/// Simple dialog with [title], [message] and a single "try again" button.
///
/// Usually displayed when some network content failed to load.
class ContentFailureDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback tryAgainAction;

  const ContentFailureDialog({
    @required this.title,
    this.message,
    @required this.tryAgainAction,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: message != null ? Text(message) : null,
      actions: [
        TextButton(
          onPressed: tryAgainAction,
          child: Text("Try again"),
        ),
      ],
    );
  }
}
