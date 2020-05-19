import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_interactive/bloc/from.dart';
import 'package:video_interactive/bloc/video_player/video_player_bloc.dart';
import 'package:video_interactive/bloc/video_player/video_player_event.dart';
import 'package:video_interactive/interactive/new_interactive_fullscreen.dart';
import 'package:video_interactive/model/interactive_new_model.dart';

abstract class InteractiveBlocV2Event {}

class LoadInteractiveEvent extends InteractiveBlocV2Event {
  final String from;
  final List<Asset> assets;
  final List<Interactive> interactives;

  LoadInteractiveEvent({ 
    @required this.from,
    @required this.assets,
    @required this.interactives,
  });
}

class NextVideoInteractiveEvent extends InteractiveBlocV2Event {
  final Interactive interactive;
  NextVideoInteractiveEvent({
    @required this.interactive
  });
}
class ChangeVideoPlayerBlocEvent extends InteractiveBlocV2Event {
  final int index;
  ChangeVideoPlayerBlocEvent({ @required this.index });
}
class OnClickHotspotEvent extends InteractiveBlocV2Event {
  final Hotspot hotspot;
  final Interactive interactive;
  OnClickHotspotEvent({
    @required this.hotspot,
    @required this.interactive,
  });
}
class FullscreenSwitchEvent extends InteractiveBlocV2Event {
  final bool fullscreen;
  final BuildContext context;
  FullscreenSwitchEvent({
    @required this.fullscreen,
    @required this.context,
  });
}
class LoadNextVideoEvent extends InteractiveBlocV2Event {
  final Interactive interactive;
  LoadNextVideoEvent({
    @required this.interactive
  });
}

// State
abstract class InteractiveBlocV2State extends Equatable {
  const InteractiveBlocV2State();

  @override
  List<Object> get props => [];
}

class InteractiveUninitializedState extends InteractiveBlocV2State {}
class InteractiveInitializedState extends InteractiveBlocV2State {

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
class InteractiveErrorState extends InteractiveBlocV2State {}

// Bloc 
class InteractiveBlocV2 extends Bloc<InteractiveBlocV2Event, InteractiveBlocV2State> {
 
  // InteractiveNewModel model;
  List<Asset> videoAssets = new List();
  List<Interactive> interactives = new List();
  List<VideoPlayerBloc> listVideoBloc = new List();
  VideoPlayerBloc _videoPlayerBloc;
  int _count = 0;

  @override
  Future<void> close() {
    _videoPlayerBloc.close();
    listVideoBloc.forEach((bloc) => bloc.close());
    return super.close();
  }

  @override
  InteractiveBlocV2State get initialState => InteractiveUninitializedState();

  @override
  Stream<InteractiveBlocV2State> mapEventToState(InteractiveBlocV2Event event) async* {
    if (event is LoadInteractiveEvent) {
      // assign interactive
      interactives = event.interactives;
      
      // assign assets
      interactives.asMap().forEach((index, interactive) {
        var data = event.assets.firstWhere(
          (asset) => asset.name == interactive.name,
          orElse: () => null
        );
        if (data != null) {
          videoAssets.add(data);
          listVideoBloc.add(VideoPlayerBloc(
            from: From.LESSON_PAGE, 
            url: data.url,
            interactive: true,
            initialized: false
          ));
        }
      });

      // get start video state
      int indexLoadFirst = interactives.indexWhere(
        (interactive) => interactive.key == "start"
      );
      
      print(videoAssets[indexLoadFirst].url);

      _videoPlayerBloc = listVideoBloc[indexLoadFirst];
      _videoPlayerBloc.initialized = true;
      _videoPlayerBloc..add(VideoInitializeEvent(
        autoPlay: false, 
        fullscreen: false,
        interactive: interactives[indexLoadFirst], 
        mute: false
      ));

      yield InteractiveInitializedState(
        videoPlayerBloc: _videoPlayerBloc, 
        count: _count++, 
        playingIndex: indexLoadFirst,
        fullscreen: false
      );
    } else if (event is LoadNextVideoEvent) {
      if (event.interactive.nextObj != "") {
        int nextIndex = interactives.indexWhere(
          (interactive) => interactive.key == event.interactive.nextObj
        );
        if (!listVideoBloc[nextIndex].initialized) {
          listVideoBloc[nextIndex].initialized = true;
          listVideoBloc[nextIndex]..add(VideoInitializeEvent(
            autoPlay: false,
            fullscreen: (state as InteractiveInitializedState).fullscreen,
            interactive: interactives[nextIndex], 
            mute: false,
          ));
          return;
        }
      } else if (event.interactive.state == "pause" && event.interactive.hotspots.length > 0) {
        event.interactive.hotspots.forEach((video) {
          var nextIndex = interactives.indexWhere(
            (interactive) => interactive.key == video.nextObj
          );
          if (!listVideoBloc[nextIndex].initialized) {
            listVideoBloc[nextIndex].initialized = true;
            listVideoBloc[nextIndex]..add(VideoInitializeEvent(
              autoPlay: false,
              fullscreen: (state as InteractiveInitializedState).fullscreen,
              interactive: interactives[nextIndex],
              mute: false
            ));
          }
        });
        return;
      } else if (event.interactive.state == "stop" && event.interactive.nextObj == "") {
        int nextIndex = interactives.indexWhere(
          (interactive) => interactive.key == "start"
        );
        if (!listVideoBloc[nextIndex].initialized) {
          listVideoBloc[nextIndex].initialized = true;
          listVideoBloc[nextIndex]..add(VideoInitializeEvent(
            autoPlay: false,
            fullscreen: (state as InteractiveInitializedState).fullscreen,
            interactive: interactives[nextIndex], 
            mute: false,
          ));
          return;
        }
      }
    } else if (event is NextVideoInteractiveEvent) {
      print("fullscreen ${(state as InteractiveInitializedState).fullscreen}");
      // return;
      if (event.interactive.state == "stop") {
        int nextIndex = interactives.indexWhere(
          (interactive) => interactive.key == "start"
        );

        if (_videoPlayerBloc != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            add(ChangeVideoPlayerBlocEvent(index: nextIndex));
          });

          // yield (state as InteractiveInitializedState).copyWith(
          //   playingIndex: nextIndex,
          //   count: _count
          // );
          Future.delayed(Duration(milliseconds: 2000), () {
            var x = interactives.indexWhere((interactive) => interactive.key == event.interactive.key);
            print("remove_video bloc index at $x ${interactives[x].name}");    
            listVideoBloc[x].close();
            listVideoBloc.removeAt(x);
            var data = videoAssets.firstWhere(
              (asset) => asset.name == interactives[x].name,
              orElse: () => null
            );
            if (data != null) {
              print("add_video bloc index at $x ${data.name}");
              listVideoBloc.insert(x, VideoPlayerBloc(
                from: From.LESSON_PAGE, 
                url: data.url,
                interactive: true,
                initialized: false
              ));
            }
          });
          return;
        }
      } else if (event.interactive.nextObj != "") {
        int nextIndex = interactives.indexWhere(
          (interactive) => interactive.key == event.interactive.nextObj
        );

        if (_videoPlayerBloc != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            add(ChangeVideoPlayerBlocEvent(index: nextIndex));
          });

          // yield (state as InteractiveInitializedState).copyWith(
          //   playingIndex: nextIndex,
          //   count: _count
          // );
          Future.delayed(Duration(milliseconds: 500), () {
            var x = interactives.indexWhere((interactive) => interactive.key == event.interactive.key);
            print("remove_video bloc index at $x ${interactives[x].name}");    
            listVideoBloc[x].close();
            listVideoBloc.removeAt(x);
            var data = videoAssets.firstWhere(
              (asset) => asset.name == interactives[x].name,
              orElse: () => null
            );
            if (data != null) {
              print("add_video bloc index at $x ${data.name}");
              listVideoBloc.insert(x, VideoPlayerBloc(
                from: From.LESSON_PAGE, 
                url: data.url,
                interactive: true,
                initialized: false
              ));
            }
          });
          return;
        }
      }
    } else if (event is ChangeVideoPlayerBlocEvent) {
      print("video ${event.index}");

      _videoPlayerBloc..add(VideoPauseEvent());
      yield (state as InteractiveInitializedState).copyWith(
        playingIndex: event.index,
        videoPlayerBloc: _videoPlayerBloc,
        count: _count
      );
      _videoPlayerBloc..add(VideoRestartEvent());

      _videoPlayerBloc = listVideoBloc[event.index];

      _videoPlayerBloc..add(VideoPlayEvent());

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
            add(ChangeVideoPlayerBlocEvent(index: nextIndex));
          });

          // yield (state as InteractiveInitializedState).copyWith(
          //   playingIndex: nextIndex,
          //   count: _count
          // );
          Future.delayed(Duration(milliseconds: 500), () {
            event.interactive.hotspots.forEach((area) {
              if (area.nextObj != event.hotspot.nextObj) {
                var x = interactives.indexWhere((interactive) => interactive.key == area.nextObj);
                print("remove_video bloc index at $x ${interactives[x].name}");
                
                listVideoBloc[x].close();
                listVideoBloc.removeAt(x);

                var data = videoAssets.firstWhere(
                  (asset) => asset.name == interactives[x].name,
                  orElse: () => null
                );
                if (data != null) {
                  print("add_video bloc index at $x ${data.name}");
                  listVideoBloc.insert(x, VideoPlayerBloc(
                    from: From.LESSON_PAGE, 
                    url: data.url,
                    interactive: true,
                    initialized: false
                  ));
                }
              }
            });
          });
          return;
        }
      }
    } else if (event is FullscreenSwitchEvent) {
      print("FullscreenSwitchEvent ${event.fullscreen}");
      listVideoBloc.forEach((bloc) {
        bloc..add(VideoFullscreenClickEvent());
      });

      var fullscreen = (state as InteractiveInitializedState).fullscreen;

      var isPortrait = MediaQuery.of(event.context).orientation == Orientation.portrait;
      print("isPortrait $isPortrait $fullscreen");

      if (!isPortrait) {
        Navigator.pop(event.context);
      } else {
        Navigator.push(event.context, MaterialPageRoute(
          builder: (BuildContext context) {
            return BlocProvider.value(
              value: this,
              child: NewInteractiveFullscreen(),
            );
          }
        ));
      }
      
      yield (state as InteractiveInitializedState).copyWith(
        fullscreen: !fullscreen,
        count: _count++
      );
      return;
    }
  }

  Future<InteractiveNewModel> getVideos() async {
    return await rootBundle.loadString("lib/json/list_video_be_gen.json")
        .then((String data) => InteractiveNewModel.fromJson(json.decode(data)));
  }

  // Future<List<Directory>> get _localPath async {
  //   final directory = await getExternalStorageDirectories(type: StorageDirectory.movies);
  //   return directory;
  // }

  // Future<String> get _localPath2 async {
  //   final directory = await getExternalStorageDirectory();
  //   return directory.path;
  // }

}