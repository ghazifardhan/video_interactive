import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_interactive/bloc/from.dart';
import 'package:video_interactive/bloc/video_player/video_player_bloc.dart';
import 'package:video_interactive/bloc/video_player/video_player_event.dart';
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
class AddMoreVideoEvent extends ListVideoBlocEvent {}
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
  final InteractiveModel model;
  final VideoPlayerBloc videoPlayerBloc;
  final List<Datum> datas;

  InitializedListVideoState({
    @required this.playingIndex,
    @required this.count,
    @required this.model,
    @required this.videoPlayerBloc,
    @required this.datas,
  });

  InitializedListVideoState copyWith({
    int playingIndex,
    int count,
    VideoPlayerController videoPlayerController,
    Future<void> initializePlayers,
    InteractiveModel model,
    VideoPlayerBloc videoPlayerBloc,
    List<Datum>  datas,
  }) {
    return InitializedListVideoState(
      playingIndex: playingIndex ?? this.playingIndex,
      count: count ?? this.count,
      model: model ?? this.model,
      videoPlayerBloc: videoPlayerBloc ?? this.videoPlayerBloc,
      datas: datas ?? this.datas,
    );
  }

  @override
  List<Object> get props => [
    playingIndex,
    count,
    model,
    videoPlayerBloc,
    datas,
  ];

  @override
  String toString() {
    print("InitializedListVideoBlocState {count: $count}");
    return super.toString();
  }

}

// Bloc

class ListVideoBloc extends Bloc<ListVideoBlocEvent, ListVideoBlocState> {

  int _count = 0;
  InteractiveModel videoModel;
  List<Datum> datas = new List<Datum>();
  int _totalVideos = 0;
  int _playingIndex = 0;
  VideoPlayerBloc _videoPlayerBloc;

  @override
  ListVideoBlocState get initialState => UninitializedListVideoState();

  @override
  Future<void> close() {
    _videoPlayerBloc.close();
    return super.close();
  }

  @override
  Stream<ListVideoBlocState> mapEventToState(ListVideoBlocEvent event) async* {
    if (event is InitializeListVideoBlocEvent) {
      videoModel = await getVideos();
      _totalVideos = videoModel.data.length;
      datas = videoModel.data;

      videoModel.data.forEach((data) {
        print("key -----> ${data.key}");
      });

      _videoPlayerBloc = VideoPlayerBloc(
        from: From.MY_COURSES, 
        url: videoModel.data[0].url,
        interactive: false
      );
      _videoPlayerBloc..add(VideoInitializeEvent(
        autoPlay: true, 
        fullscreen: false,
        interactive: null
      ));

      yield InitializedListVideoState(
        playingIndex: _playingIndex,
        count: _count++,
        model: videoModel,
        videoPlayerBloc: _videoPlayerBloc,
        datas: datas
      );
    } else if (event is PlayListVideoBlocEvent) {
      _videoPlayerBloc = VideoPlayerBloc(from: From.MY_COURSES, url: videoModel.data[event.playingIndex].url, interactive: false);
      _videoPlayerBloc..add(VideoInitializeEvent(
        autoPlay: true, 
        fullscreen: false,
        interactive: null
      ));

      yield (state as InitializedListVideoState).copyWith(
        playingIndex: event.playingIndex,
        videoPlayerBloc: _videoPlayerBloc,
        count: _count++,
      );
    } else if (event is ChangeVideoPlayerEvent) {
      if (event.playingIndex != (state as InitializedListVideoState).playingIndex) {
        if (_videoPlayerBloc != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _videoPlayerBloc..add(UninitializedVideoPlayerEvent());
            
            Future.delayed(Duration(seconds: 2), () {
              final oldPlayer = _videoPlayerBloc;
              oldPlayer.close();
              print("mantap gan addPostFrameCallback");
              add(PlayListVideoBlocEvent(playingIndex: event.playingIndex));
            });
          });

          yield (state as InitializedListVideoState).copyWith(
            playingIndex: event.playingIndex,
            count: _count
          );
          
          // _videoPlayerBloc = null;

          

          // Future.delayed(Duration(seconds: 2), () {
          //   add(PlayListVideoBlocEvent(playingIndex: event.playingIndex));
          // });
        }
      }
    } else if (event is AddMoreVideoEvent) {
      var newModel = await getVideos();
      datas.addAll(newModel.data);

      yield (state as InitializedListVideoState).copyWith(
        datas: datas
      );
    }
  }

  Future<InteractiveModel> getVideos() async {
    return await rootBundle.loadString("lib/json/video.json")
        .then((String data) => InteractiveModel.fromJson(json.decode(data)));
  }

}