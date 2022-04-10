import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({Key? key, this.message, this.withScaffold = false})
      : super(key: key);

  final String? message;
  final bool? withScaffold;

  @override
  Widget build(BuildContext context) {
    final data = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        if (message != null) Text(message!),
      ],
    );

    return withScaffold!
        ? Scaffold(
            body: data,
          )
        : data;
  }
}
