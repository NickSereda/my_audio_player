import 'package:flutter/material.dart';

SnackBar getErrorMessageSnackBar(BuildContext context) {
  return SnackBar(
    backgroundColor: Theme.of(context).colorScheme.error,
    content: Text(
      'An error has occurred while loading audio',
      style: Theme.of(context)
          .textTheme
          .subtitle1
          .copyWith(color: Theme.of(context).colorScheme.onError),
    ),
    duration: const Duration(seconds: 2),
  );
}