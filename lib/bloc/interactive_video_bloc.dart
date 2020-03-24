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

  final String from;

  InitializeInteractiveVideoEvent({ @required this.from });

}

class NextInteractiveVideoEvent extends InteractiveVideoEvent {
//  final int nextVideo;
//
//  NextInteractiveVideoEvent({ @required this.nextVideo });
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

class FullscreenVideoEvent extends InteractiveVideoEvent {}

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
  final bool fullscreen;

  InitializedInteractiveVideoState({
    @required this.playingIndex,
    @required this.videoBloc,
    @required this.count,
    @required this.videoPlayerController,
    @required this.initializePlayers,
    @required this.model,
    @required this.fullscreen,
  });

  InitializedInteractiveVideoState copyWith({
    int playingIndex,
    VideoBloc videoBloc,
    int count,
    VideoPlayerController videoPlayerController,
    Future<void> initializePlayers,
    InteractiveModel model,
    bool fullscreen,
  }) {
    return InitializedInteractiveVideoState(
      videoBloc: videoBloc ?? this.videoBloc,
      playingIndex: playingIndex ?? this.playingIndex,
      count: count ?? this.count,
      videoPlayerController: videoPlayerController ?? this.videoPlayerController,
      initializePlayers: initializePlayers ?? this.initializePlayers,
      model: model ?? this.model,
      fullscreen: fullscreen ?? this.fullscreen,
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
    fullscreen,
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
  bool _disposed = false;
  var _isPlaying = false;
  var _isEndPlaying = false;
  int _count = 0;
  int _playingIndex = 0;
  int _totalVideos = 0;
  InteractiveModel videoModel;
  VideoPlayerController currentController;
  Future<void> currentInitializePlayer;

  @override
  InteractiveVideoState get initialState => UninitializedInteractiveVideoState();

  @override
  Future<void> close() {
    _controllers.forEach((controller) {
      controller?.pause();
      controller?.removeListener(videoListener);
      controller?.dispose();
    });
    currentController?.pause();
    currentController?.removeListener(videoListener);
    currentController?.dispose();
    return super.close();
  }

  Future<void> _clearPrevious(int index) async {
    await _controllers[index].pause();
    _controllers[index]?.removeListener(videoListener);
  }

  Future<void> _controllerListener(index) async {
    if (_controllers[index] == null || _disposed) {
      return;
    }
    if (!_controllers[index].value.initialized) {
      return;
    }

    final position = await _controllers[index].position;
    final duration = await _controllers[index].value.duration;
    final isPlaying = position.inMilliseconds < duration.inMilliseconds;
    final isEndPlaying = position.inMilliseconds > 0 && position.inSeconds == duration.inSeconds;

    if (_isPlaying != isPlaying || _isEndPlaying != isEndPlaying) {
      _isPlaying = isPlaying;
      _isEndPlaying = isEndPlaying;
      print("$_playingIndex -----> isPlaying=$isPlaying / isCompletePlaying=$isEndPlaying");
      if (isEndPlaying) {
        final isComplete = _playingIndex == videoModel.data.length - 1;
        if (isComplete) {
          print("played all");
        } else {
          _startPlay(index + 1);
        }
      }
    }
  }

  Future<void> _startPlay(int index) async {
    print("play ---------> $index");
    Future.delayed(const Duration(milliseconds: 200), () {
      _clearPrevious(index).then((_){
//        _initializePlay(index);
        add(PlayInteractiveVideoEvent(index: index));
      });
    });
  }

  @override
  Stream<InteractiveVideoState> mapEventToState(InteractiveVideoEvent event) async* {

    if (event is InitializeInteractiveVideoEvent) {

      videoModel = await getVideos();
      _totalVideos = videoModel.data.length;

      if (event.from == "network") {
        videoModel.data.forEach((data) {
          _controllers.add(VideoPlayerController.network(data.url));
        });
      } else {
        videoModel.data.forEach((data) {
          _controllers.add(VideoPlayerController.asset(data.asset));
        });
      }

      _controllers.asMap().forEach((index, controller) {
        _initializePlayers.add(controller.initialize());
      });

      currentController = _controllers[0];
      currentInitializePlayer = _initializePlayers[0];

      add(AddControllerListenerEvent(index: 0));

      yield InitializedInteractiveVideoState(
        playingIndex: _playingIndex,
        videoBloc: null,
        count: _count++,
        videoPlayerController: currentController,
        initializePlayers: currentInitializePlayer,
        model: videoModel,
        fullscreen: true
      );
    } else if (event is PlayInteractiveVideoEvent) {

      await currentController.seekTo(Duration(seconds: 0));
      await currentController.play();

      yield (state as InitializedInteractiveVideoState).copyWith(
        playingIndex: event.index,
        count: _count++,
        videoPlayerController: currentController
      );

    } else if (event is StopInteractiveVideoEvent) {
      await currentController.pause();

      yield (state as InitializedInteractiveVideoState).copyWith(
        playingIndex: event.index,
        count: _count++,
        videoPlayerController: currentController
      );
    } else if (event is NextInteractiveVideoEvent) {

      int index = (state as InitializedInteractiveVideoState).playingIndex;
      print("next will be ${videoModel.data[index].nextVideos}");
      if (videoModel.data[index].nextVideos > 0) {
        currentController = _controllers[videoModel.data[index].nextVideos];
        currentInitializePlayer = _initializePlayers[videoModel.data[index].nextVideos];
        add(AddControllerListenerEvent(index: 0));

        add(PlayInteractiveVideoEvent(index: videoModel.data[index].nextVideos));
      }

    } else if (event is AddControllerListenerEvent) {

      if (currentController.hasListeners) {
        currentController.removeListener(videoListener);
      }
      currentController.addListener(videoListener);

    } else if (event is OnClickHotspotEvent) {
      currentController = _controllers[event.nextVideo];
      currentInitializePlayer = _initializePlayers[event.nextVideo];
      add(AddControllerListenerEvent(index: 0));

      add(PlayInteractiveVideoEvent(index: event.nextVideo));
    } else if (event is FullscreenVideoEvent) {
      yield (state as InitializedInteractiveVideoState).copyWith(
        fullscreen: !(state as InitializedInteractiveVideoState).fullscreen,
        count: _count++
      );
    }

//    if (event is InitializeInteractiveVideoEvent) {
//      videoModel = await getVideos();
//      _totalVideos = videoModel.data.length;
//      videoModel.data.forEach((data) {
//        _controllers.add(VideoPlayerController.asset(data.asset));
//      });
//
//      _controllers.asMap().forEach((index, controller) {
//        controller.addListener(() => videoListener(index));
//        _initializePlayers.add(controller.initialize());
//      });
//
//      print("controller ${_controllers.length} future ${_initializePlayers.length}");
//
////      add(AddControllerListenerEvent(index: _playingIndex));
//
//      yield InitializedInteractiveVideoState(
//        playingIndex: _playingIndex,
//        videoBloc: null,
//        count: _count++,
//        videoPlayerController: _controllers[_playingIndex],
//        initializePlayers: _initializePlayers[_playingIndex],
//        model: videoModel
//      );
//    } else if (event is NextInteractiveVideoEvent) {
//
//      // Stop Current video
////      add(StopInteractiveVideoEvent());
//      // Increment playing index
//
//      add(PlayInteractiveVideoEvent(index: event.nextVideo));
//      add(AddControllerListenerEvent(index: event.nextVideo));
//
//      yield (state as InitializedInteractiveVideoState).copyWith(
//        playingIndex: event.nextVideo,
//      );
//    } else if (event is PlayInteractiveVideoEvent) {
//      print("playing index ${event.index}");
//      await _controllers[event.index].seekTo(Duration(seconds: 0));
//      await _controllers[event.index].play();
//
//      yield (state as InitializedInteractiveVideoState).copyWith(
//        count: _count++,
//        videoPlayerController: _controllers[event.index],
//        playingIndex: event.index
//      );
//    } else if (event is StopInteractiveVideoEvent) {
//      print("stopped index ${event.index}");
//      _controllers[event.index].pause();
//
//      yield (state as InitializedInteractiveVideoState).copyWith(
//        count: _count++,
//        videoPlayerController: _controllers[event.index],
//        playingIndex: event.index
//      );
//    } else if (event is AddControllerListenerEvent) {
//      if (!_controllers[event.index].hasListeners) {
//        _controllers[event.index].addListener(() => videoListener(event.index));
//      }
//    } else if (event is OnClickHotspotEvent) {
//      print("to index ${event.nextVideo}");
//      // Stop Current video
////      add(StopInteractiveVideoEvent());
//      add(NextInteractiveVideoEvent(nextVideo: event.nextVideo));
//    }
  }

  Future<InteractiveModel> getVideos() async {
    return await rootBundle.loadString("lib/json/video.json")
        .then((String data) => InteractiveModel.fromJson(json.decode(data)));
  }

  videoListener() {
    if (currentController.value.position == currentController.value.duration) {
        add(NextInteractiveVideoEvent());
    }
  }

}