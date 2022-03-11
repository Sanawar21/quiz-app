import 'package:flutter/material.dart';

class MessageDialogPopUp extends StatelessWidget {
  final String message;

  MessageDialogPopUp(this.message);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // title: Text("My title"),
      content: Text(message),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
