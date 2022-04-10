import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({Key? key, this.message, this.withScaffold = false})
      : super(key: key);

  final String? message;
  final bool? withScaffold;

  @override
  Widget build(BuildContext context) {
    final data = Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Chip(
                label: Text(
                  message!,
                  softWrap: true,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      ?.copyWith(color: Colors.white),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );

    return withScaffold!
        ? Scaffold(
            body: data,
          )
        : data;
  }
}
