import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_interactive/bloc/from.dart';
import 'package:video_interactive/bloc/video_player/video_player_bloc.dart';
import 'package:video_interactive/bloc/video_player/video_player_event.dart';
import 'package:video_interactive/model/interactive_new_model.dart';

abstract class InteractiveBlocEvent {}
class LoadInteractiveEvent extends InteractiveBlocEvent {}
class NextVideoInteractiveEvent extends InteractiveBlocEvent {
  final Interactive interactive;
  NextVideoInteractiveEvent({
    @required this.interactive
  });
}
class ChangeVideoPlayerBlocEvent extends InteractiveBlocEvent {
  final int index;
  ChangeVideoPlayerBlocEvent({ @required this.index });
}
class OnClickHotspotEvent extends InteractiveBlocEvent {
  final Hotspot hotspot;
  OnClickHotspotEvent({
    @required this.hotspot
  });
}
class FullscreenSwitchEvent extends InteractiveBlocEvent {
  final bool fullscreen;
  FullscreenSwitchEvent({
    @required this.fullscreen
  });
}

// State
abstract class InteractiveBlocState extends Equatable {
  const InteractiveBlocState();

  @override
  List<Object> get props => [];
}

class InteractiveUninitializedState extends InteractiveBlocState {}
class InteractiveInitializedState extends InteractiveBlocState {

  final VideoPlayerBloc videoPlayerBloc;
  final int count;
  final int playingIndex;
  final bool fullscreen;

  InteractiveInitializedState({
    @required this.videoPlayerBloc,
    @required this.count,
    @required this.playingIndex,
    @required this.fullscreen,
  });
  
  InteractiveInitializedState copyWith({
    VideoPlayerBloc videoPlayerBloc,
    int count,
    int playingIndex,
    bool fullscreen,
  }) {
    return InteractiveInitializedState(
      count: count ?? this.count,
      videoPlayerBloc: videoPlayerBloc ?? this.videoPlayerBloc,
      playingIndex: playingIndex ?? this.playingIndex,
      fullscreen: fullscreen ?? this.fullscreen,
    );
  }

  @override
  List<Object> get props => [
    count,
    videoPlayerBloc,
    playingIndex
  ];
}
class InteractiveErrorState extends InteractiveBlocState {}

// Bloc 
class InteractiveBloc extends Bloc<InteractiveBlocEvent, InteractiveBlocState> {
 
  InteractiveNewModel model;
  List<Asset> videoAssets = new List();
  List<Interactive> interactives = new List();
  List<VideoPlayerBloc> listVideoBloc = new List();
  VideoPlayerBloc _videoPlayerBloc;
  int _count = 0;

  @override
  Future<void> close() {
    // _videoPlayerBloc.close();
    return super.close();
  }

  @override
  InteractiveBlocState get initialState => InteractiveUninitializedState();

  @override
  Stream<InteractiveBlocState> mapEventToState(InteractiveBlocEvent event) async* {
    if (event is LoadInteractiveEvent) {
      model = await getVideos();

      // assign interactive
      interactives = model.blocks.firstWhere(
        (block) => block.type == "Video Interactive",
        orElse: null,
      ).content.interactive;

      // assign assets
      interactives.asMap().forEach((index, interactive) {
        var data = model.assets.firstWhere(
          (asset) => asset.name == interactive.name,
          orElse: () => null
        );
        if (data != null) {
          videoAssets.add(data);
          listVideoBloc.add(VideoPlayerBloc(
            from: From.LESSON_PAGE, 
            url: data.url,
            interactive: true
          ));
        }
      });

      // initialized all video bloc
      // listVideoBloc.asMap().forEach((index, bloc) {
      //   bloc..add(VideoInitializeEvent(
      //     autoPlay: false, 
      //     fullscreen: false,
      //     interactive: interactives[index]
      //   ));
      // });

      // get start video state
      int indexLoadFirst = interactives.indexWhere(
        (interactive) => interactive.key == "start"
      );
      
      print(videoAssets[indexLoadFirst].url);

      // _videoPlayerBloc = listVideoBloc[indexLoadFirst];
      _videoPlayerBloc = VideoPlayerBloc(
        from: From.LESSON_PAGE, 
        url: videoAssets[indexLoadFirst].url,
        interactive: true
      );
      _videoPlayerBloc..add(VideoInitializeEvent(
        autoPlay: false, 
        fullscreen: false,
        interactive: interactives[indexLoadFirst]
      ));

      yield InteractiveInitializedState(
        videoPlayerBloc: _videoPlayerBloc, 
        count: _count++, 
        playingIndex: indexLoadFirst,
        fullscreen: false
      );
    } else if (event is NextVideoInteractiveEvent) {
      if (event.interactive.state == "stop") {
        int nextIndex = interactives.indexWhere(
          (interactive) => interactive.key == "start"
        );

        if (_videoPlayerBloc != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _videoPlayerBloc..add(UninitializedVideoPlayerEvent());

            Future.delayed(Duration(seconds: 2), () {
              final oldPlayer = _videoPlayerBloc;
              oldPlayer.close();
              print("mantap gan addPostFrameCallback");
              add(ChangeVideoPlayerBlocEvent(index: nextIndex));
            });
          });

          yield (state as InteractiveInitializedState).copyWith(
            playingIndex: nextIndex,
            count: _count
          );
          return;
        }
      } else if (event.interactive.nextObj != "") {
        int nextIndex = interactives.indexWhere(
          (interactive) => interactive.key == event.interactive.nextObj
        );

        if (_videoPlayerBloc != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _videoPlayerBloc..add(UninitializedVideoPlayerEvent());

            Future.delayed(Duration(seconds: 2), () {
              final oldPlayer = _videoPlayerBloc;
              oldPlayer.close();
              print("mantap gan addPostFrameCallback");
              add(ChangeVideoPlayerBlocEvent(index: nextIndex));
            });
          });

          yield (state as InteractiveInitializedState).copyWith(
            playingIndex: nextIndex,
            count: _count
          );
          return;
        }
      }
    } else if (event is ChangeVideoPlayerBlocEvent) {
      print("fullscreen switch ${(state as InteractiveInitializedState).fullscreen}");
      _videoPlayerBloc = VideoPlayerBloc(from: From.LESSON_PAGE, url: videoAssets[event.index].url, interactive: true);
      _videoPlayerBloc..add(VideoInitializeEvent(
        autoPlay: true, 
        fullscreen: (state as InteractiveInitializedState).fullscreen,
        interactive: interactives[event.index]
      ));

      yield (state as InteractiveInitializedState).copyWith(
        playingIndex: event.index,
        videoPlayerBloc: _videoPlayerBloc,
        count: _count
      );
    } else if (event is OnClickHotspotEvent) {
      if (event.hotspot.nextObj != "") {
        int nextIndex = interactives.indexWhere(
          (interactive) => interactive.key == event.hotspot.nextObj
        );

        if (_videoPlayerBloc != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _videoPlayerBloc..add(UninitializedVideoPlayerEvent());

            Future.delayed(Duration(seconds: 2), () {
              final oldPlayer = _videoPlayerBloc;
              oldPlayer.close();
              print("mantap gan addPostFrameCallback");
              add(ChangeVideoPlayerBlocEvent(index: nextIndex));
            });
          });

          yield (state as InteractiveInitializedState).copyWith(
            playingIndex: nextIndex,
            count: _count
          );
        }
        // add(NextVideoInteractiveEvent(
        //   interactive: next
        // ));
      }
    } else if (event is FullscreenSwitchEvent) {
      print("FullscreenSwitchEvent ${event.fullscreen}");
      yield (state as InteractiveInitializedState).copyWith(
        fullscreen: event.fullscreen,
        count: _count++
      );
    }
  }

  Future<InteractiveNewModel> getVideos() async {
    return await rootBundle.loadString("lib/json/new_video.json")
        .then((String data) => InteractiveNewModel.fromJson(json.decode(data)));
  }

}