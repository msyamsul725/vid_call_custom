import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LiveChatTimer extends StatefulWidget {
  final String timeChatAgent;
  final Function liveChatTimeout;
  final Function? liveChatReminder;
  final Color color;
  final Function? defaultEndAction;

  LiveChatTimer(
      {required this.timeChatAgent,
      required this.liveChatTimeout,
this.liveChatReminder,
      this.defaultEndAction,
      required this.color});

  @override
  _LiveChatState createState() => _LiveChatState();
}

class _LiveChatState extends State<LiveChatTimer> {
  String? timeDifference;
  Timer? _timer;
  bool reminderCalled = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void didUpdateWidget(LiveChatTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.timeChatAgent != oldWidget.timeChatAgent) {
      startTimer();
    }
  }

  void startTimer() {
    _timer?.cancel(); // Cancel previous timer if any
    if (widget.timeChatAgent.isNotEmpty) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        final DateTime now = DateTime.now();
        final DateTime targetTime = DateTime.parse(widget.timeChatAgent);
        final int differenceInSeconds = targetTime.difference(now).inSeconds;

        // Check if timeChatAgent is not today
        final bool isNotToday = targetTime.day != now.day ||
            targetTime.month != now.month ||
            targetTime.year != now.year;

        if (differenceInSeconds <= 0 || isNotToday) {
          timer.cancel();
          setState(() {
            timeDifference = null;
          });
          widget.liveChatTimeout();
          if (widget.defaultEndAction != null) {
            widget.defaultEndAction!();
          }
          return;
        }

        String formattedTime;

        // Jika waktu berbeda dalam jam yang sama
        if (now.hour == targetTime.hour) {
          final int remainingMinutes = differenceInSeconds ~/ 60;
          final int remainingSeconds = differenceInSeconds % 60;

          // Format waktu mundur tanpa menampilkan jam jika kurang dari satu jam
          formattedTime =
              "$remainingMinutes:${remainingSeconds < 10 ? '0$remainingSeconds' : remainingSeconds} ( $remainingMinutes Menit $remainingSeconds Detik )";
        } else {
          // Jika waktu berbeda dalam jam yang berbeda
          final int remainingHours = differenceInSeconds ~/ 3600;
          final int remainingMinutes = (differenceInSeconds % 3600) ~/ 60;
          final int remainingSeconds = differenceInSeconds % 60;

          // Format waktu mundur dengan menampilkan jam
          formattedTime =
              "$remainingHours:${remainingMinutes < 10 ? '0$remainingMinutes' : remainingMinutes}:${remainingSeconds < 10 ? '0$remainingSeconds' : remainingSeconds} ( $remainingHours Jam $remainingMinutes Menit $remainingSeconds Detik )";
        }

        setState(() {
          timeDifference = formattedTime;
        });

        // Panggil liveChatReminder ketika waktu tersisa kurang dari 2 menit
        if (differenceInSeconds < 120 && !reminderCalled) {
          widget.liveChatReminder!(formattedTime);
          reminderCalled =
              true; // Set reminderCalled to true to call liveChatReminder only once
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: timeDifference != null
            ? Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.0,
                    color: Colors.orange,
                  ),
                ),
                child: Text(
                  timeDifference!,
                  style: TextStyle(fontSize: 12, color: widget.color),
                ),
              )
            : Center(
                child: LoadingAnimationWidget.prograssiveDots(
                color: const Color(0xFFEA3799),
                size: MediaQuery.sizeOf(context).width * 0.1,
              )));
  }
}
