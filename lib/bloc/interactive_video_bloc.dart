import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_interactive/bloc/video_bloc.dart';
import 'package:video_interactive/model/interactive_model.dart';
import 'package:video_player/video_player.dart';

abstract class InteractiveVideoEvent {}

class InitializeInteractiveVideoEvent extends InteractiveVideoEvent {

  final List<String> videoUrls;

  InitializeInteractiveVideoEvent({ @required this.videoUrls });

}

class NextInteractiveVideoEvent extends InteractiveVideoEvent {
  final int nextVideo;

  NextInteractiveVideoEvent({ @required this.nextVideo });
}
class PlayInteractiveVideoEvent extends InteractiveVideoEvent {
  final int index;

  PlayInteractiveVideoEvent({ @required this.index });
}
class StopInteractiveVideoEvent extends InteractiveVideoEvent {
  final int index;

  StopInteractiveVideoEvent({ @required this.index });
}
class AddControllerListenerEvent extends InteractiveVideoEvent {
  final int index;

  AddControllerListenerEvent({ @required this.index });
}
class OnClickHotspotEvent extends InteractiveVideoEvent {

  final int nextVideo;

  OnClickHotspotEvent({ @required this.nextVideo });

}

// State

abstract class InteractiveVideoState extends Equatable {
  const InteractiveVideoState();

  @override
  List<Object> get props => [];
}

class UninitializedInteractiveVideoState extends InteractiveVideoState {}

class InitializedInteractiveVideoState extends InteractiveVideoState {

  final int playingIndex;
  final VideoBloc videoBloc;
  final int count;
  final VideoPlayerController videoPlayerController;
  final Future<void> initializePlayers;
  final InteractiveModel model;

  InitializedInteractiveVideoState({
    @required this.playingIndex,
    @required this.videoBloc,
    @required this.count,
    @required this.videoPlayerController,
    @required this.initializePlayers,
    @required this.model,
  });

  InitializedInteractiveVideoState copyWith({
    int playingIndex,
    VideoBloc videoBloc,
    int count,
    VideoPlayerController videoPlayerController,
    Future<void> initializePlayers,
    InteractiveModel model,
  }) {
    return InitializedInteractiveVideoState(
      videoBloc: videoBloc ?? this.videoBloc,
      playingIndex: playingIndex ?? this.playingIndex,
      count: count ?? this.count,
      videoPlayerController: videoPlayerController ?? this.videoPlayerController,
      initializePlayers: initializePlayers ?? this.initializePlayers,
      model: model ?? this.model,
    );
  }

  @override
  List<Object> get props => [
    videoBloc,
    playingIndex,
    count,
    initializePlayers,
    videoPlayerController,
    model,
  ];

  @override
  String toString() {
    print("InitializedInteractiveVideoState {count: $count}");
    return super.toString();
  }
}

// Bloc
class InteractiveVideoBloc extends Bloc<InteractiveVideoEvent, InteractiveVideoState> {

  List<VideoBloc> _videoBlocs = new List<VideoBloc>();
  List<VideoPlayerController> _controllers = new List<VideoPlayerController>();
  List<Future<void>> _initializePlayers = new List<Future<void>>();
  int _count = 0;
  int _playingIndex = 0;
  int _totalVideos = 0;
  InteractiveModel videoModel;

  @override
  InteractiveVideoState get initialState => UninitializedInteractiveVideoState();

  @override
  Future<void> close() {
    _controllers.forEach((controller) {
      controller?.pause();
      controller?.removeListener(() => videoListener(0));
      controller?.dispose();
    });
    return super.close();
  }

  @override
  Stream<InteractiveVideoState> mapEventToState(InteractiveVideoEvent event) async* {
    if (event is InitializeInteractiveVideoEvent) {
      videoModel = await getVideos();
      _totalVideos = videoModel.data.length;
      videoModel.data.forEach((data) {
        _controllers.add(VideoPlayerController.network(data.url));
      });

      _controllers.forEach((controller) {
        _initializePlayers.add(controller.initialize());
      });

      print("controller ${_controllers.length} future ${_initializePlayers.length}");

      _controllers[_playingIndex].play();

      add(AddControllerListenerEvent(index: _playingIndex));

      yield InitializedInteractiveVideoState(
        playingIndex: _playingIndex,
        videoBloc: null,
        count: _count++,
        videoPlayerController: _controllers[_playingIndex],
        initializePlayers: _initializePlayers[_playingIndex],
        model: videoModel
      );
    } else if (event is NextInteractiveVideoEvent) {

      // Stop Current video
//      add(StopInteractiveVideoEvent());
      // Increment playing index

      add(PlayInteractiveVideoEvent(index: event.nextVideo));
      add(AddControllerListenerEvent(index: event.nextVideo));

      yield (state as InitializedInteractiveVideoState).copyWith(
        playingIndex: event.nextVideo,
      );
    } else if (event is PlayInteractiveVideoEvent) {
      print("playing index ${event.index}");
      _controllers[event.index].seekTo(Duration(seconds: 0));
      _controllers[event.index].play();

      yield (state as InitializedInteractiveVideoState).copyWith(
        count: _count++,
        videoPlayerController: _controllers[event.index],
        playingIndex: event.index
      );
    } else if (event is StopInteractiveVideoEvent) {
      print("stopped index ${_playingIndex-1}");
      _controllers[(_playingIndex-1)].pause();

      yield (state as InitializedInteractiveVideoState).copyWith(
        count: _count++,
        videoPlayerController: _controllers[(_playingIndex-1)],
        playingIndex: event.index
      );
    } else if (event is AddControllerListenerEvent) {
      if (!_controllers[event.index].hasListeners) {
        _controllers[event.index].addListener(() => videoListener(event.index));
      }
    } else if (event is OnClickHotspotEvent) {
      print("to index ${event.nextVideo}");
      // Stop Current video
//      add(StopInteractiveVideoEvent());
      add(NextInteractiveVideoEvent(nextVideo: event.nextVideo));
    }
  }

  Future<InteractiveModel> getVideos() async {
    return await rootBundle.loadString("lib/json/video.json")
        .then((String data) => InteractiveModel.fromJson(json.decode(data)));
  }

  videoListener(int _playingIndex) {
    if (_controllers[_playingIndex].value.initialized) {
      if (_controllers[_playingIndex].value.position == _controllers[_playingIndex].value.duration) {
        print("playingIndex $_playingIndex stopped");
        if (_playingIndex < (_totalVideos - 1)) {
          if (videoModel.data[_playingIndex].nextVideos > -1) {
            add(NextInteractiveVideoEvent(nextVideo: videoModel.data[_playingIndex].nextVideos));
          }
        }
      }
    }
  }

}