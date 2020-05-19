import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_interactive/bloc/from.dart';
import 'package:video_interactive/bloc/video_bloc.dart';
import 'package:video_interactive/bloc/video_player/video_player_event.dart';
import 'package:video_interactive/bloc/video_player/video_player_state.dart';
import 'package:video_interactive/model/interactive_new_model.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {

  final From from;
  final bool interactive;
  Interactive interactiveData;
  VideoPlayerController videoPlayerController;
  Future<void> initializeVideoPlayer;
  String url;
  int minutes = 0;
  int seconds = 0;
  int currentMinutes = 0;
  int currentSeconds = 0;
  String title;
  bool initialized;

  Stream<void> _videoPlayerController;

  VideoPlayerBloc({
    @required this.url,
    @required this.from,
    @required this.initialized,
    this.title,
    this.interactive
  });

  @override
  Future<void> close() async {
    print("disposed gans");
    final oldPlayer  = videoPlayerController;
    oldPlayer?.pause();
    oldPlayer?.removeListener(videoListener);
    await oldPlayer?.dispose();

    videoPlayerController = null;

    return super.close();
  }

  @override
  VideoPlayerState get initialState => VideoUninitializedState();

  Stream<VideoPlayerState> _mapToInitializeNew(VideoPlayerEvent event) async* {
    if (event is VideoInitializeEvent) {
      interactiveData = event.interactive;
      if (videoPlayerController == null) {
        print("video player is nulls");

        // var link = await DefaultCacheManager().getFileFromCache(url);
        // if (link != null) {
        //   print("ada filenya gan");
        //   videoPlayerController = new VideoPlayerController.file(File(link.file.path));
        // } else {
        //   print("ga ada filenya gan");
        //   var fileStream = DefaultCacheManager().getFileStream(url, withProgress: true);
        //   fileStream.listen((onData) {
        //     var test = onData as DownloadProgress;
        //     print("$url : ${test.downloaded} ${test.totalSize}");
        //       // print("onData ${onData.originalUrl}");
        //     },
        //     onDone: () {
        //       print("Download Done gan");
        //     }
        //   );
        //   videoPlayerController = new VideoPlayerController.network(url);
        // }
        

        // videoPlayerController = new VideoPlayerController.file(File(url));
        videoPlayerController = new VideoPlayerController.network(url);
        videoPlayerController..initialize().then((_) {
          add(VideoDoneInitializedEvent(
            videoPlayerController: videoPlayerController,
            initializeVideoController: initializeVideoPlayer,
            minutes: videoPlayerController.value.duration.inSeconds ~/ 60,
            seconds: videoPlayerController.value.duration.inSeconds % 60,
            fullscreen: event.fullscreen,
            autoPlay: event.autoPlay,
            interactive: event.interactive
          ));
        });
      }
    }
  }

  Stream<VideoPlayerState> _mapToInitialize(VideoPlayerEvent event) async* {
    yield VideoInitializedState(
      first: true,
      loading: false,
      show: false,
      videoPlayerController: videoPlayerController,
      autoPlay: false,
      forward: false,
      rewind: false,
      url: url,
      initializeVideoPlayer: initializeVideoPlayer,
      minutes: 0,
      seconds: 0,
      currentSeconds: 0,
      currentMinutes: 0,
      fullscreen: false,
      play: false,
      videoHeight: 200,
      title: title,
      buffer: true
    );

    initializeVideoPlayer = videoPlayerController.initialize();
    _videoPlayerController = Stream.fromFuture(initializeVideoPlayer);
    _videoPlayerController.listen((data) {
      debugPrint("DataReceived:");
      debugPrint("controller $videoPlayerController");

      add(VideoDoneInitializedEvent(
        videoPlayerController: videoPlayerController,
        initializeVideoController: initializeVideoPlayer,
        minutes: videoPlayerController.value.duration.inSeconds ~/ 60,
        seconds: videoPlayerController.value.duration.inSeconds % 60
      ));

      add(VideoAddListenerEvent());
    }, onDone: () {
      debugPrint("Task Done");
    }, onError: (error) {
      debugPrint("Some Error ${error.toString()}");
    });
  }

  @override
  Stream<VideoPlayerState> mapEventToState(VideoPlayerEvent event) async* {
    if (event is VideoOnClickEvent) {
      yield (state as VideoInitializedState).copyWith(
          show: !(state as VideoInitializedState).show
      );
      if ((state as VideoInitializedState).show) {
        Timer(const Duration(seconds: 2), () {
          add(VideoOnDismissEvent());
        });
        // Future.delayed(Duration(seconds: 2), () {
        //   add(VideoOnDismissEvent());
        //   // yield (state as VideoInitializedState).copyWith(
        //   //   show: false
        //   // );
        // });
      }
    } else if (event is VideoPauseEvent) {
      if (videoPlayerController != null && videoPlayerController.value.initialized) {
        // await videoPlayerController.seekTo(Duration(seconds: 0));
        await videoPlayerController.pause();
        yield (state as VideoInitializedState).copyWith(
          videoPlayerController: videoPlayerController,
          show: true,
          first: false,
          play: false,
          end: false
        );
        return;
      }
    } else if (event is VideoInitializeEvent) {
      try {
        if (state is VideoUninitializedState) {
          yield* _mapToInitializeNew(event);
        }
      } catch (_) {
        yield VideoErrorState();
      }
    } else if (event is VideoPlayEvent) {
      try {
        if (state is VideoInitializedState) {
          if (videoPlayerController != null && videoPlayerController.value.initialized) {
            if (videoPlayerController.value.position == videoPlayerController.value.duration) {
              videoPlayerController.seekTo(Duration(seconds: 0));
              videoPlayerController.play();
            } else {
              videoPlayerController.play();
            }

            yield (state as VideoInitializedState).copyWith(
              videoPlayerController: videoPlayerController,
              show: false,
              first: false,
              play: true,
              end: false
            );

            if ((state as VideoInitializedState).first) {
              Timer(const Duration(seconds: 2), () {
                add(VideoOnDismissEvent());
              });
            }
            return;
          }
        }
      } catch (_) {
        yield VideoErrorState();
      }
    } else if (event is VideoRestartEvent) {
      if (state is VideoInitializedState) {
        if (videoPlayerController != null && videoPlayerController.value.initialized) {
          videoPlayerController.seekTo(Duration(seconds: 0));
          // videoPlayerController.play();

          yield (state as VideoInitializedState).copyWith(
            videoPlayerController: videoPlayerController,
            show: false,
            first: false,
            play: true
          );

          if ((state as VideoInitializedState).first) {
            Timer(const Duration(seconds: 2), () {
              add(VideoOnDismissEvent());
            });
          }
          
          return;
        }
      }
    } else if (event is VideoForwardEvent) {
      if (videoPlayerController != null && videoPlayerController.value.initialized) {
        if ((videoPlayerController.value.duration.inSeconds - videoPlayerController.value.position.inSeconds) <= 10) {
          videoPlayerController.seekTo(Duration(seconds: videoPlayerController.value.duration.inSeconds));
        } else {
          videoPlayerController.seekTo(Duration(seconds: videoPlayerController.value.position.inSeconds + 10));
        }
        yield (state as VideoInitializedState).copyWith(
          videoPlayerController: videoPlayerController,
          forward: true
        );
        return;
      }
    } else if (event is VideoRewindEvent) {
      if (videoPlayerController != null && videoPlayerController.value.initialized){
        if (videoPlayerController.value.position.inSeconds <= 10) {
          videoPlayerController.seekTo(Duration(seconds: 0));
        } else {
          videoPlayerController.seekTo(Duration(seconds: videoPlayerController.value.position.inSeconds - 5));
        }
        yield (state as VideoInitializedState).copyWith(
          rewind: true,
          videoPlayerController: videoPlayerController
        );
      }
    } else if (event is VideoOnEndEvent) {
      if (interactiveData.state == "stop") {
        yield (state as VideoInitializedState).copyWith(
          first: true,
          show: false,
          end: true,
          lastVideo: true
        );
      } else {
        yield (state as VideoInitializedState).copyWith(
          first: true,
          show: false,
          end: true,
          lastVideo: false
        );
      }
    } else if (event is VideoForwardBlockOffEvent) {
      yield (state  as VideoInitializedState).copyWith(
        forward: false
      );
    } else if (event is VideoRewindBlockOffEvent) {
      yield (state  as VideoInitializedState).copyWith(
        rewind: false
      );
    } else if (event is VideoFullscreenClickEvent) {

      var fullscreen = !(state as VideoInitializedState).fullscreen;
      print("fullscreen $fullscreen");
      if (from == From.COURSE_SUMMARY) {
        if (fullscreen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SystemChrome.setEnabledSystemUIOverlays([]);
            SystemChrome.setPreferredOrientations(
                [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
            SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
          });
        }
      }

      yield (state as VideoInitializedState).copyWith(
        fullscreen: fullscreen
      );

    } else if(event is VideoDoneInitializedEvent) {

      if (from == From.COURSE_SUMMARY) {
        if (event.fullscreen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SystemChrome.setEnabledSystemUIOverlays([]);
            SystemChrome.setPreferredOrientations(
                [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
            SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
          });
        }
      }

      var play = event.autoPlay;

      yield VideoInitializedState(
          first: true,
          loading: false,
          show: false,
          videoPlayerController: event.videoPlayerController,
          autoPlay: event.autoPlay,
          forward: false,
          rewind: false,
          url: url,
          initializeVideoPlayer: event.initializeVideoController,
          minutes: event.minutes,
          seconds: event.seconds,
          currentSeconds: 0,
          currentMinutes: 0,
          fullscreen: event.fullscreen,
          play: play,
          videoHeight: 200,
          title: title,
          end: false,
          lastVideo: false,
          interactive: event.interactive,
          position: Duration(seconds: 0),
          buffer: true,
          duration: event.videoPlayerController.value.duration
      );

      add(VideoAddListenerEvent());

      Timer(const Duration(milliseconds: 500), () {
        if (event.autoPlay) {
          add(VideoPlayEvent());
        }
      });
      // Future.delayed(Duration(seconds: 2), () {
      //   if (event.autoPlay) {
      //     add(VideoPlayEvent());
      //   }
      // });
      return;
//      yield (state as VideoInitializedState).copyWith(
//        videoPlayerController: event.videoPlayerController,
//        initializeVideoPlayer: event.initializeVideoController,
//        minutes: event.minutes,
//        seconds: event.seconds
//      );
    } else if(event is VideoAddListenerEvent) {
      if (state is VideoInitializedState) {
        videoPlayerController.removeListener(videoListener);
        if (!videoPlayerController.hasListeners) {
          videoPlayerController.addListener(videoListener);
        }
      }
    } else if (event is VideoDurationListenerEvent) {
      if (state is VideoInitializedState) {
        yield (state as VideoInitializedState).copyWith(
          minutes: event.minutes,
          seconds: event.seconds,
          currentSeconds: event.currentSeconds,
          currentMinutes: event.currentMinutes,
          position: event.position
        );
      }
    } else if (event is VideoHeightEvent) {
      yield (state as VideoInitializedState).copyWith(
        videoHeight: event.height
      );
    } else if (event is VideoOnDismissEvent) {
      yield (state as VideoInitializedState).copyWith(
        show: false
      );
      return;
    } else if (event is UninitializedVideoPlayerEvent) {
      yield VideoUninitializedState();
      return;
    } else if (event is VideoOnBufferEvent) {
      if (state is VideoInitializedState) {
        yield (state as VideoInitializedState).copyWith(
          buffer: event.buffer
        );
      }
    }
  }

  videoListener() {
    if (videoPlayerController.value.initialized) {
      minutes = videoPlayerController.value.duration.inSeconds ~/ 60;
      seconds = videoPlayerController.value.duration.inSeconds % 60;

      currentMinutes = videoPlayerController.value.position.inSeconds ~/ 60;
      currentSeconds = videoPlayerController.value.position.inSeconds % 60;
      add(VideoDurationListenerEvent(
          minutes: minutes,
          seconds: seconds,
          currentMinutes: currentMinutes,
          currentSeconds: currentSeconds,
          position: videoPlayerController.value.position
      ));

      if (videoPlayerController.value.position == videoPlayerController.value.duration) {
        add(VideoOnEndEvent());
      }
    }
  }

}

