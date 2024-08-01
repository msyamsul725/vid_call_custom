// File: zego_uikit_prebuilt_call/lib/zego_call_duration_time_board.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_uikit_prebuilt_call/src/components/timer_live_chat.dart';
import 'package:zego_uikit_prebuilt_call/src/controller_holder.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZegoCallDurationTimeBoard extends StatefulWidget {
  final ValueNotifier<Duration> durationNotifier;
  final double fontSize;
  final void Function(ZegoCallEndEvent event) defaultEndAction;

  const ZegoCallDurationTimeBoard({
    Key? key,
    required this.durationNotifier,
    required this.defaultEndAction,
    this.fontSize = 18,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ZegoCallDurationTimeBoardState();
}

class _ZegoCallDurationTimeBoardState extends State<ZegoCallDurationTimeBoard> {
  final controller = ControllerHolder().chatNewController;

  @override
  void dispose() {
    widget.durationNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  bool snackbarShown = false;
  final callEndEvent = ZegoCallEndEvent(
    callID: ZegoUIKit().getRoom().id,
    reason: ZegoCallEndReason.localHangUp,
    isFromMinimizing: ZegoCallMiniOverlayPageState.minimizing ==
        ZegoUIKitPrebuiltCallController().minimize.state,
  );

  void defaultAction() {
    widget.defaultEndAction(callEndEvent);
  }

  int minutesCall = 0;
  int minutes = 0;
  int remainingMinutes = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration>(
      valueListenable: widget.durationNotifier,
      builder: (context, elapsedTime, _) {
        final durationString = durationFormatString(elapsedTime);

        final textStyle = TextStyle(
            color: Colors.white,
            decoration: TextDecoration.none,
            fontSize: widget.fontSize);

        return Column(
          children: [
            Text(
              durationString,
              textAlign: TextAlign.center,
              style: textStyle,
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.64),
            controller.timeCallAgent! != null
                ? LiveChatTimer(
                    defaultEndAction: () {
                      defaultAction();
                    },
                    color: Colors.white,
                    timeChatAgent: controller.timeCallAgent!,
                    liveChatTimeout: () {
                      printInfo();
                    },
                    liveChatReminder: (String formattedTime) {
                      !controller.isAdminCheckNew
                          ? controller.reminderLiveCall(formattedTime)
                          : printInfo();
                    },
                  )
                : const Text(
                    'Your session has ended as the time limit for the video call has been reached. Please try again later or contact support for further assistance.'),
          ],
        );
      },
    );
  }

  String durationFormatString(Duration elapsedTime) {
    final hours = elapsedTime.inHours;
    final minutes = elapsedTime.inMinutes.remainder(60);
    final seconds = elapsedTime.inSeconds.remainder(60);

    final minutesFormatString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return hours > 0
        ? '${hours.toString().padLeft(2, '0')}:$minutesFormatString'
        : minutesFormatString;
  }

  String calculateCountdownString(int minutes) {
    final DateTime now = DateTime.now();
    final DateTime targetTime = now.add(Duration(minutes: minutes));
    Duration remainingDuration = targetTime.difference(now);

    final hours = remainingDuration.inHours;
    final minutesLeft = remainingDuration.inMinutes.remainder(60);
    final secondsLeft = remainingDuration.inSeconds.remainder(60);

    final minutesString = minutesLeft.toString().padLeft(2, '0');
    final secondsString = secondsLeft.toString().padLeft(2, '0');

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutesString:$secondsString';
    } else {
      return '$minutesString:$secondsString';
    }
  }
}
