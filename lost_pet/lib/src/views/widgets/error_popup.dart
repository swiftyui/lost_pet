import 'package:flutter/material.dart';
import 'package:lost_pet/src/services/theme.dart';

class ErrorPopup extends StatelessWidget {
  final String title;
  final String message;

  const ErrorPopup({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'OK',
            style: dialogActionTextStyle(Theme.of(context).colorScheme),
          ),
        ),
      ],
    );
  }
}
