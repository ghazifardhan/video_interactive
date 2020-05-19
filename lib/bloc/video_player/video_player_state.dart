import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:video_interactive/model/interactive_new_model.dart';
import 'package:video_player/video_player.dart';

@immutable
abstract class VideoPlayerState extends Equatable {
  const VideoPlayerState();

  @override
  List<Object> get props => [];
}

class VideoUninitializedState extends VideoPlayerState {}

class VideoInitializedState extends VideoPlayerState {
  final VideoPlayerController videoPlayerController;
  final bool play;
  final bool show;
  final bool first;
  final bool loading;
  final bool autoPlay;
  final bool forward;
  final bool rewind;
  final bool end;
  final String url;
  final Future<void> initializeVideoPlayer;
  final int minutes;
  final int seconds;
  final int currentMinutes;
  final int currentSeconds;
  final bool fullscreen;
  final double videoHeight;
  final String title;
  final Interactive interactive;
  final Duration position;
  final Duration duration;
  final bool lastVideo;
  final bool buffer;

  const VideoInitializedState({
    this.videoPlayerController,
    this.play,
    this.show,
    this.first,
    this.loading,
    this.autoPlay,
    this.forward,
    this.rewind,
    this.end,
    this.buffer,
    this.lastVideo,
    this.url,
    this.initializeVideoPlayer,
    this.minutes,
    this.seconds,
    this.currentMinutes,
    this.currentSeconds,
    this.fullscreen,
    this.videoHeight,
    this.title,
    this.interactive,
    this.position,
    this.duration,
  });

  VideoInitializedState copyWith({
    VideoPlayerController videoPlayerController,
    bool play,
    bool show,
    bool first,
    bool loading,
    bool autoPlay,
    bool forward,
    bool rewind,
    bool end,
    bool lastVideo,
    bool buffer,
    String url,
    Future<void> initializeVideoPlayer,
    int minutes,
    int seconds,
    int currentMinutes,
    int currentSeconds,
    bool fullscreen,
    double videoHeight,
    String title,
    Interactive interactive,
    Duration position,
    Duration duration,
  }) {
    return VideoInitializedState(
      videoPlayerController: videoPlayerController ?? this.videoPlayerController,
      play: play ?? this.play,
      first: first ?? this.first,
      loading: loading ?? this.loading,
      autoPlay: autoPlay ?? this.autoPlay,
      forward: forward ?? this.forward,
      rewind: rewind ?? this.rewind,
      end: end ?? this.end,
      url: url ?? this.url,
      lastVideo: lastVideo ?? this.lastVideo,
      show: show ?? this.show,
      initializeVideoPlayer: initializeVideoPlayer ?? this.initializeVideoPlayer,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
      currentMinutes: currentMinutes ?? this.currentMinutes,
      currentSeconds: currentSeconds ?? this.currentSeconds,
      fullscreen: fullscreen ?? this.fullscreen,
      videoHeight: videoHeight ?? this.videoHeight,
      title: title ?? this.title,
      interactive: interactive ?? this.interactive,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      buffer: buffer ?? this.buffer,
    );
  }

  @override
  List<Object> get props => [
    videoPlayerController,
    play,
    show,
    first,
    loading,
    autoPlay,
    forward,
    end,
    lastVideo,
    rewind,
    url,
    initializeVideoPlayer,
    minutes,
    seconds,
    currentMinutes,
    currentSeconds,
    fullscreen,
    videoHeight,
    title,
    interactive,
    position,
    duration,
    buffer,
  ];
}

class VideoErrorState extends VideoPlayerState {}