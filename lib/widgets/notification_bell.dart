import 'package:flutter/material.dart';

///This class places a notification bell in the upper right-hand corner that will
///shake in-place occasionally. It takes in a function to be called once the bell is pressed.
class NotificationBell extends StatelessWidget {
  final void Function() func;

  const NotificationBell({required this.func, super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topRight,
        child: Container(
            height: 40.0,
            width: 40.0,
            margin: EdgeInsets.only(right: 15.0, top: 15.0),
            child: Stack(children: [
              IconButton(
                  icon: const Icon(Icons.notifications_active),
                  tooltip: "Click to see notifications",
                  onPressed: func)
            ])));
  }
}
