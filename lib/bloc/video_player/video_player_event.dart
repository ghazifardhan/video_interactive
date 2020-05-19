import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_interactive/model/interactive_new_model.dart';
import 'package:video_player/video_player.dart';

abstract class VideoPlayerEvent extends Equatable {
  const VideoPlayerEvent();

  @override
  List<Object> get props => [];
}

class UninitializedVideoPlayerEvent extends VideoPlayerEvent {}

class VideoInitializeEvent extends VideoPlayerEvent {
  final bool fullscreen;
  final bool autoPlay;
  final Interactive interactive;
  final bool mute;

  VideoInitializeEvent({
    @required this.fullscreen,
    @required this.autoPlay,
    @required this.interactive, 
    @required this.mute,
  });
}

class VideoDoneInitializedEvent extends VideoPlayerEvent {
  final VideoPlayerController videoPlayerController;
  final Future<void> initializeVideoController;
  final int minutes;
  final int seconds;
  final bool fullscreen;
  final bool autoPlay;
  final Interactive interactive;
  final bool mute;

  const VideoDoneInitializedEvent({
    this.videoPlayerController,
    this.initializeVideoController,
    this.minutes,
    this.seconds,
    this.fullscreen,
    this.autoPlay,
    this.interactive,
    this.mute,
  });

  VideoDoneInitializedEvent copyWith({
    VideoPlayerController videoPlayerController,
    Future<void> initializeVideoController,
    int minutes,
    int seconds,
    bool fullscreen,
    bool autoPlay,
    Interactive interactive,
    bool mute,
  }) {
    return VideoDoneInitializedEvent(
      videoPlayerController: videoPlayerController ?? this.videoPlayerController,
      initializeVideoController: initializeVideoController ?? this.initializeVideoController,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
      fullscreen: fullscreen ?? this.fullscreen,
      autoPlay: autoPlay ?? this.autoPlay,
      interactive: interactive ?? this.interactive,
      mute: mute ?? this.mute,
    );
  }

  @override
  List<Object> get props => [
    videoPlayerController,
    initializeVideoController,
    fullscreen,
    autoPlay,
    interactive,
    mute,
  ];
}

class VideoOnClickEvent extends VideoPlayEvent {}

class VideoPlayEvent extends VideoPlayerEvent {}

class VideoPauseEvent extends VideoPlayerEvent {}

class VideoRestartEvent extends VideoPlayerEvent {}

class VideoForwardEvent extends VideoPlayerEvent {}

class VideoRewindEvent extends VideoPlayerEvent {}

class VideoOnEndEvent extends VideoPlayerEvent {}

class VideoForwardBlockOffEvent extends VideoPlayerEvent {}

class VideoRewindBlockOffEvent extends VideoPlayerEvent {}

class VideoFullscreenClickEvent extends VideoPlayerEvent {}

class VideoAddListenerEvent extends VideoPlayerEvent {}

class VideoDurationListenerEvent extends VideoPlayerEvent {
  final int minutes;
  final int seconds;
  final int currentMinutes;
  final int currentSeconds;
  final Duration position;

  VideoDurationListenerEvent({
    @required this.minutes,
    @required this.seconds,
    @required this.currentMinutes,
    @required this.currentSeconds,
    @required this.position,
  });

  VideoDurationListenerEvent copyWith({
    int minutes,
    int seconds,
    int currentMinutes,
    int currentSeconds,
    Duration position,
  }) {
    return VideoDurationListenerEvent(
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
      currentMinutes: currentMinutes ?? this.currentMinutes,
      currentSeconds: currentSeconds ?? this.currentSeconds,
      position: position ?? this.position
    );
  }

  @override
  List<Object> get props => [
    minutes,
    seconds,
    currentMinutes,
    currentSeconds,
    position,
  ];
}

class VideoHeightEvent extends VideoPlayerEvent {
  final double height;

  VideoHeightEvent({ @required this.height });
}

class VideoOnDismissEvent extends VideoPlayerEvent {}

class VideoOnBufferEvent extends VideoPlayerEvent {
  final bool buffer;
  VideoOnBufferEvent({ @required this.buffer });
}
class VideoMuteEvent extends VideoPlayerEvent {}