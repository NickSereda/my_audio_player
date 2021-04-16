import 'package:flutter/material.dart';

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
        FlatButton(
          onPressed: tryAgainAction,
          child: Text("Try again"),
        ),
      ],
    );
  }
}
