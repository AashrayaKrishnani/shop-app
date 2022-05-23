import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog(
      {Key? key,
      this.title = 'Dev Messed Up! 😅',
      this.content =
          'You can be Nice and send us a ScreenShot of this (at loveaash3@gmail.com) so we can solve it out! 🙏',
      this.buttonMessage = 'Ahh Alright!'})
      : super(key: key);

  final String title;
  final String content;
  final String buttonMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).errorColor,
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      content: Text(
        content,
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red)),
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            )),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white)),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              buttonMessage,
              style: const TextStyle(color: Colors.red),
            ))
      ],
    );
  }
}
