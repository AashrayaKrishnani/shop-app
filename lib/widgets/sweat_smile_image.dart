import 'package:flutter/material.dart';

class SweatSmileImage extends StatelessWidget {
  const SweatSmileImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height / 4;

    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, h, 0, 0),
          child: Center(
            child: SizedBox.square(
              dimension: h,
              child: FittedBox(
                child: Image.network(
                    'https://png.pngitem.com/pimgs/s/106-1061780_emoji-transparent-download-smiling-with-sweat-emoji-covent.png'),
              ),
            ),
          ),
        ));
  }
}
