import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_interactive/model/interactive_model.dart';
import 'package:video_player/video_player.dart';

// Event

abstract class ListVideoBlocEvent {}

class InitializeListVideoBlocEvent extends ListVideoBlocEvent {}
class PlayListVideoBlocEvent extends ListVideoBlocEvent {
  final int playingIndex;

  PlayListVideoBlocEvent({ @required this.playingIndex});
}
class StopListVideoBlocEvent extends ListVideoBlocEvent {}
class ChangeVideoPlayerEvent extends ListVideoBlocEvent {
  final int playingIndex;

  ChangeVideoPlayerEvent({ @required this.playingIndex});
}
class AddControllerListVideoBlocEvent extends ListVideoBlocEvent {}

// State

abstract class ListVideoBlocState extends Equatable {
  const ListVideoBlocState();

  @override
  List<Object> get props => [];
}

class UninitializedListVideoState extends ListVideoBlocState {}
class InitializedListVideoState extends ListVideoBlocState {

  final int playingIndex;
  final int count;
  final VideoPlayerController videoPlayerController;
  final Future<void> initializePlayers;
  final InteractiveModel model;

  InitializedListVideoState({
    @required this.playingIndex,
    @required this.count,
    @required this.videoPlayerController,
    @required this.initializePlayers,
    @required this.model,
  });

  InitializedListVideoState copyWith({
    int playingIndex,
    int count,
    VideoPlayerController videoPlayerController,
    Future<void> initializePlayers,
    InteractiveModel model,
  }) {
    return InitializedListVideoState(
      playingIndex: playingIndex ?? this.playingIndex,
      count: count ?? this.count,
      videoPlayerController: videoPlayerController ?? this.videoPlayerController,
      initializePlayers: initializePlayers ?? this.initializePlayers,
      model: model ?? this.model,
    );
  }

  @override
  List<Object> get props => [
    playingIndex,
    count,
    initializePlayers,
    videoPlayerController,
    model,
  ];

  @override
  String toString() {
    print("InitializedListVideoBlocState {count: $count}");
    return super.toString();
  }

}

// Bloc

class ListVideoBloc extends Bloc<ListVideoBlocEvent, ListVideoBlocState> {

  List<VideoPlayerController> _controllers = new List<VideoPlayerController>();
  List<Future<void>> _initializePlayers = new List<Future<void>>();
  int _count = 0;
  VideoPlayerController currentController;
  Future<void> currentInitializePlayer;
  InteractiveModel videoModel;
  int _totalVideos = 0;
  int _playingIndex = 0;

  @override
  ListVideoBlocState get initialState => UninitializedListVideoState();

  @override
  Future<void> close() {
    _controllers.forEach((controller) {
      controller?.pause();
//      controller?.removeListener(videoListener);
      controller?.dispose();
    });
    currentController?.pause();
//    currentController?.removeListener(videoListener);
    currentController?.dispose();
    return super.close();
  }

  @override
  Stream<ListVideoBlocState> mapEventToState(ListVideoBlocEvent event) async* {
    if (event is InitializeListVideoBlocEvent) {
      videoModel = await getVideos();
      _totalVideos = videoModel.data.length;


      videoModel.data.forEach((data) {
        print("key -----> ${data.key}");
        _controllers.add(VideoPlayerController.asset(data.asset));
      });

      _controllers.asMap().forEach((index, controller) {
        _initializePlayers.add(controller.initialize());
      });

      currentController = _controllers[0];
      currentInitializePlayer = _initializePlayers[0];
      currentController.setVolume(0.0);

      yield InitializedListVideoState(
        playingIndex: _playingIndex,
        count: _count++,
        videoPlayerController: currentController,
        initializePlayers: currentInitializePlayer,
        model: videoModel
      );
    } else if (event is PlayListVideoBlocEvent) {
      if (event.playingIndex != (state as InitializedListVideoState).playingIndex) {
        await currentController.setVolume(0.0);
        await currentController.seekTo(Duration(seconds: 0));
        await currentController.play();

        yield (state as InitializedListVideoState).copyWith(
            playingIndex: event.playingIndex,
//        count: _count++,
            videoPlayerController: currentController
        );
      } else if (event.playingIndex == 0) {
        await currentController.setVolume(0.0);
        await currentController.seekTo(Duration(seconds: 0));
        await currentController.play();

        yield (state as InitializedListVideoState).copyWith(
            playingIndex: event.playingIndex,
//        count: _count++,
            videoPlayerController: currentController
        );
      }
    } else if (event is ChangeVideoPlayerEvent) {
      currentController = _controllers[event.playingIndex];
      currentInitializePlayer = _initializePlayers[event.playingIndex];

      add(PlayListVideoBlocEvent(
        playingIndex: event.playingIndex
      ));
    }
  }

  Future<InteractiveModel> getVideos() async {
    return await rootBundle.loadString("lib/json/video.json")
        .then((String data) => InteractiveModel.fromJson(json.decode(data)));
  }

}