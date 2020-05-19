import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_interactive/bloc/interactive_video_bloc.dart';
import 'package:video_interactive/interactive/video_page.dart';
import 'package:video_interactive/model/interactive_new_model.dart';
import 'package:video_player/video_player.dart';

abstract class InteractiveVideoEvent {}

class InitializeInteractiveVideoEvent extends InteractiveVideoEvent {

  final String from;

  InitializeInteractiveVideoEvent({ 
    @required this.from,
  });

}

class NextInteractiveVideoEvent extends InteractiveVideoEvent {
//  final int nextVideo;
//
//  NextInteractiveVideoEvent({ @required this.nextVideo });
}
class PlayInteractiveVideoEvent extends InteractiveVideoEvent {
  final int index;
  final bool first;
  PlayInteractiveVideoEvent({ 
    @required this.index,
    @required this.first
  });
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

  final String nextVideo;

  OnClickHotspotEvent({ @required this.nextVideo });

}

class FullscreenVideoEvent extends InteractiveVideoEvent {
  BuildContext context;
  InteractiveVideoNewBloc interactiveVideoNewBloc;
  FullscreenVideoEvent({ @required this.context, @required this.interactiveVideoNewBloc });
}
class VideoOnClickEvent extends InteractiveVideoEvent {}
class VideoOnDismissOverlayEvent extends InteractiveVideoEvent {}
class UpdateTimeVideoEvent extends InteractiveVideoEvent {
  int currentMiliseconds;

  UpdateTimeVideoEvent({ @required this.currentMiliseconds });
}
class RestartVideoEvent extends InteractiveVideoEvent{}
class DetectBufferingVideoEvent extends InteractiveVideoEvent {
  final bool isBuffering;
  DetectBufferingVideoEvent({ @required this.isBuffering });
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
  final int count;
  final VideoPlayerController videoPlayerController;
  final Future<void> initializePlayers;
  final bool fullscreen;
  final List<Asset> videoAssets;
  final List<Interactive> interactive;

  final bool play;
  final bool show;
  final bool first;
  final bool loading;
  final bool autoPlay;
  final bool forward;
  final bool rewind;
  final int minutes;
  final int seconds;
  final int currentMinutes;
  final int currentSeconds;
  final int currentMiliseconds;
  final bool isEndVideo;
  final bool isBuffering;

  InitializedInteractiveVideoState({
    @required this.playingIndex,
    @required this.count,
    @required this.videoPlayerController,
    @required this.initializePlayers,
    @required this.fullscreen,
    @required this.videoAssets,
    @required this.interactive,
    @required this.play,
    @required this.show,
    @required this.first,
    @required this.loading,
    @required this.autoPlay,
    @required this.forward,
    @required this.rewind,
    @required this.minutes,
    @required this.seconds,
    @required this.currentMinutes,
    @required this.currentSeconds,
    @required this.currentMiliseconds,
    @required this.isEndVideo,
    @required this.isBuffering,
  });

  InitializedInteractiveVideoState copyWith({
    int playingIndex,
    int count,
    VideoPlayerController videoPlayerController,
    Future<void> initializePlayers,
    bool fullscreen,
    List<Asset> videoAssets,
    List<Interactive> interactive,
    bool play,
    bool show,
    bool first,
    bool loading,
    bool autoPlay,
    bool forward,
    bool rewind,
    int minutes,
    int seconds,
    int currentMinutes,
    int currentSeconds,
    int currentMiliseconds,
    bool isEndVideo,
    bool isBuffering,
  }) {
    return InitializedInteractiveVideoState(
      playingIndex: playingIndex ?? this.playingIndex,
      count: count ?? this.count,
      videoPlayerController: videoPlayerController ?? this.videoPlayerController,
      initializePlayers: initializePlayers ?? this.initializePlayers,
      fullscreen: fullscreen ?? this.fullscreen,
      videoAssets: videoAssets ?? this.videoAssets,
      interactive: interactive ?? this.interactive,
      play: play ?? this.play,
      first: first ?? this.first,
      loading: loading ?? this.loading,
      autoPlay: autoPlay ?? this.autoPlay,
      forward: forward ?? this.forward,
      rewind: rewind ?? this.rewind,
      show: show ?? this.show,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
      currentMinutes: currentMinutes ?? this.currentMinutes,
      currentSeconds: currentSeconds ?? this.currentSeconds,
      currentMiliseconds: currentMiliseconds ?? this.currentMiliseconds,
      isEndVideo: isEndVideo ?? this.isEndVideo,
      isBuffering: isBuffering ?? this.isBuffering,
    );
  }

  @override
  List<Object> get props => [
    playingIndex,
    count,
    initializePlayers,
    videoPlayerController,
    fullscreen,
    videoAssets,
    interactive,
    play,
    show,
    first,
    loading,
    autoPlay,
    forward,
    rewind,
    minutes,
    seconds,
    currentMinutes,
    currentSeconds,
    currentMiliseconds,
    isEndVideo,
    isBuffering,
  ];

  @override
  String toString() {
    print("InitializedInteractiveVideoState {count: $count}");
    return super.toString();
  }
}

// Bloc
class InteractiveVideoNewBloc extends Bloc<InteractiveVideoEvent, InteractiveVideoState> {

  // List<VideoBloc> _videoBlocs = new List<VideoBloc>();
  List<VideoPlayerController> _controllers = new List<VideoPlayerController>();
  List<Future<void>> _initializePlayers = new List<Future<void>>();
  bool _disposed = false;
  var _isPlaying = false;
  var _isEndPlaying = false;
  int _count = 0;
  int _playingIndex = 0;
  int _totalVideos = 0;
  // InteractiveModel videoModel;
  VideoPlayerController currentController;
  Future<void> currentInitializePlayer;

  // New
  List<Asset> videoAssets;
  List<Interactive> interactives;

  @override
  InteractiveVideoState get initialState => UninitializedInteractiveVideoState();

  @override
  Future<void> close() {
    _controllers.forEach((controller) {
      controller?.pause();
      controller?.removeListener(videoListener);
      controller?.dispose();
    });
    // currentController?.pause();
    // currentController?.removeListener(videoListener);
    // currentController?.dispose();
    return super.close();
  }

  @override
  Stream<InteractiveVideoState> mapEventToState(InteractiveVideoEvent event) async* {

    if (event is InitializeInteractiveVideoEvent) {

      InteractiveNewModel model = await getVideos();

      videoAssets = model.assets;
      interactives = model.blocks.firstWhere(
        (block) => block.type == "Video Interactive",
        orElse: null,
      ).content.interactive;

      _totalVideos = interactives.length;

      interactives.asMap().forEach((index, interactive) {
        var data = videoAssets.firstWhere(
          (asset) => asset.name == interactive.name,
          orElse: null
        );
        if (data != null) {
          _controllers.add(VideoPlayerController.network(data.url));
        }
      });
      _controllers.asMap().forEach((index, controller) {
        _initializePlayers.add(controller.initialize());
      });

      int indexLoadFirst = interactives.indexWhere((interactive) => interactive.key == "start");
      
      print("ini index pertama gan $indexLoadFirst");

      currentController = _controllers[indexLoadFirst];
      currentInitializePlayer = _initializePlayers[indexLoadFirst];

      add(AddControllerListenerEvent(index: 0));

      yield InitializedInteractiveVideoState(
        playingIndex: indexLoadFirst,
        count: _count++,
        videoPlayerController: currentController,
        initializePlayers: currentInitializePlayer,
        fullscreen: false,
        videoAssets: videoAssets,
        interactive: interactives,
        show: true,
        play: false,
        first: true,
        loading: false,
        forward: false,
        rewind: false,
        minutes: 0,
        seconds: 0,
        currentMinutes: 0,
        currentSeconds: 0,
        autoPlay: false, 
        currentMiliseconds: 0, 
        isEndVideo: false, 
        isBuffering: currentController.value.isBuffering
      );
    } else if (event is PlayInteractiveVideoEvent) {

      if (currentController != null && currentController.value.initialized) {

        print("ada apa ini ${event.first}");
        if (event.first) {
          await currentController.seekTo(Duration(milliseconds: 0));
        }
        await currentController.play();

        yield (state as InitializedInteractiveVideoState).copyWith(
          playingIndex: event.index,
          count: _count++,
          videoPlayerController: currentController
        );
        return;
      }

    } else if (event is StopInteractiveVideoEvent) {
      await currentController.pause();

      yield (state as InitializedInteractiveVideoState).copyWith(
        playingIndex: event.index,
        count: _count++,
        videoPlayerController: currentController
      );
    } else if (event is NextInteractiveVideoEvent) {

      int index = (state as InitializedInteractiveVideoState).playingIndex;
      print("next will be ${interactives[index].nextObj}");

      // is the latest video
      if (interactives[index].state == "stop") {
        print("${interactives[index].key} is the end of the video");
        yield (state as InitializedInteractiveVideoState).copyWith(
          play: false,
          show: true,
          isEndVideo: true,
        );
      }

      if (interactives[index].nextObj != "") {
        int videoIndex = interactives.indexWhere(
          (interactive) => interactive.key == interactives[index].nextObj,
        );
        
        currentController = _controllers[videoIndex];
        currentInitializePlayer = _initializePlayers[videoIndex];
        add(AddControllerListenerEvent(index: 0));

        add(PlayInteractiveVideoEvent(index: videoIndex, first: true));
      }

    } else if (event is AddControllerListenerEvent) {

      if (currentController.hasListeners) {
        currentController.removeListener(videoListener);
      }
      currentController.addListener(videoListener);

    } else if (event is OnClickHotspotEvent) {
      int videoIndex = interactives.indexWhere(
        (interactive) => interactive.key == event.nextVideo,
      );

      currentController = _controllers[videoIndex];
      currentInitializePlayer = _initializePlayers[videoIndex];
      add(AddControllerListenerEvent(index: 0));

      add(PlayInteractiveVideoEvent(index: videoIndex, first: true));
    } else if (event is FullscreenVideoEvent) {
      var fs = !(state as InitializedInteractiveVideoState).fullscreen;
      print("fullscreen $fs");
      yield (state as InitializedInteractiveVideoState).copyWith(
        fullscreen: fs,
        count: _count++
      );
      if (fs) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SystemChrome.setEnabledSystemUIOverlays([]);
          SystemChrome.setPreferredOrientations(
              [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
        });
        Navigator.push(
          event.context, 
          MaterialPageRoute(
            builder: (context) => VideoPage(interactiveVideoNewBloc: event.interactiveVideoNewBloc)
          )
        );
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
          SystemChrome.setPreferredOrientations(
              [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
        });
        Navigator.pop(event.context);
      }
    } else if (event is VideoOnClickEvent) {
      yield (state as InitializedInteractiveVideoState).copyWith(
          show: !(state as InitializedInteractiveVideoState).show
      );
      if ((state as InitializedInteractiveVideoState).show)
      Future.delayed(Duration(seconds: 2), () {
        add(VideoOnDismissOverlayEvent());
      });
    } else if (event is VideoOnDismissOverlayEvent) {
      yield (state as InitializedInteractiveVideoState).copyWith(
        show: false
      );
    } else if (event is UpdateTimeVideoEvent) {
      yield (state as InitializedInteractiveVideoState).copyWith(
        currentMiliseconds: event.currentMiliseconds
      );
    } else if(event is RestartVideoEvent) {

      yield (state as InitializedInteractiveVideoState).copyWith(
        show: false,
        play: true,
        isEndVideo: false
      );

      int indexLoadFirst = interactives.indexWhere((interactive) => interactive.key == "start");

      currentController = _controllers[indexLoadFirst];
      currentInitializePlayer = _initializePlayers[indexLoadFirst];
      add(AddControllerListenerEvent(index: 0));
      add(PlayInteractiveVideoEvent(index: indexLoadFirst, first: true));
    } else if (event is DetectBufferingVideoEvent) {
      print("buffer ${event.isBuffering}");
      yield (state as InitializedInteractiveVideoState).copyWith(
        isBuffering: event.isBuffering
      );
    }
  }

  Future<InteractiveNewModel> getVideos() async {
    return await rootBundle.loadString("lib/json/new_video.json")
        .then((String data) => InteractiveNewModel.fromJson(json.decode(data)));
  }

  videoListener() {
    add(DetectBufferingVideoEvent(isBuffering: currentController.value.isBuffering));
    if (currentController.value.initialized) {
      if (currentController.value.isPlaying) {
        if (currentController.value.position <= currentController.value.duration) {
          add(UpdateTimeVideoEvent(currentMiliseconds: currentController.value.position.inMilliseconds));
        }
      } else {
        if (currentController.value.position == currentController.value.duration) {
          add(NextInteractiveVideoEvent());
        }
      }
    }
  }

}