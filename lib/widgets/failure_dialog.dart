import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class FailureDialog extends StatelessWidget {
  final String title;
  final VoidCallback tryAgainAction;

  const FailureDialog({
    required this.title,
    required this.tryAgainAction,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformAlertDialog(
      title: Text(title),
      actions: [
        TextButton(
          onPressed: tryAgainAction,
          child: Text("Try again"),
        ),
      ],
    );
  }
}
