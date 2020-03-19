
// Event

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

abstract class VideoEvent {}
class InitializeVideoEvent extends VideoEvent {
  final String videoUrl;

  InitializeVideoEvent({ @required this.videoUrl });
}
class DoneInitializeVideoEvent extends VideoEvent {}
class PlayVideoEvent extends VideoEvent {}
class StopVideoEvent extends VideoEvent {}
class NextVideoEvent extends VideoEvent {}

// State

abstract class VideoState extends Equatable {
  const VideoState();

  @override
  List<Object> get props => [];
}

class InitializeVideoState extends VideoState {

  final VideoPlayerController controller;
  final Future<void> initializedPlayer;
  final int count;
  final int videoIndex;

  InitializeVideoState ({
    @required this.controller,
    @required this.initializedPlayer,
    @required this.count,
    @required this.videoIndex,
  });

  InitializeVideoState copyWith ({
    VideoPlayerController controller,
    Future<void> initializedPlayer,
    int count,
    int videooIndex,
  }) {
    return InitializeVideoState(
      controller: controller ?? this.controller,
      initializedPlayer: initializedPlayer ?? this.initializedPlayer,
      count: count ?? this.count,
      videoIndex: videoIndex ?? this.videoIndex,
    );
  }

  @override
  List<Object> get props => [controller, initializedPlayer, count, videoIndex];

  @override
  String toString() {
    print("InitializeVideoState {count: $count}");
    return super.toString();
  }

}

class UninitializedVideoState extends VideoState {}

// Bloc

class VideoBloc extends Bloc<VideoEvent, VideoState> {

  VideoPlayerController controller;
  Future<void> initializePlayer;
  int count = 0;

  @override
  VideoState get initialState => UninitializedVideoState();

  @override
  Stream<VideoState> mapEventToState(VideoEvent event) async* {
    if (event is InitializeVideoEvent) {
      controller = VideoPlayerController.network(event.videoUrl);
      initializePlayer = controller.initialize();
      initializePlayer.then((_) {
        add(DoneInitializeVideoEvent());
      });
    } else if (event is DoneInitializeVideoEvent) {
      yield InitializeVideoState(
        controller: controller,
        initializedPlayer: initializePlayer,
        count: count++,
        videoIndex: 0
      );
    } else if (event is PlayVideoEvent) {
      controller.play();
      yield (state as InitializeVideoState).copyWith(
        controller: controller,
        count: count++
      );
    } else if (event is StopVideoEvent) {
      controller.pause();
      yield (state as InitializeVideoState).copyWith(
        controller: controller,
        count: count++
      );
    }
  }

}