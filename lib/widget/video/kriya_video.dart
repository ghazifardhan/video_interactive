import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:video_interactive/bloc/from.dart';
import 'package:video_interactive/bloc/interactive_bloc.dart';
import 'package:video_interactive/bloc/video_player/video_player_bloc.dart';
import 'package:video_interactive/bloc/video_player/video_player_event.dart';
import 'package:video_interactive/bloc/video_player/video_player_state.dart';
import 'package:video_interactive/interactive/new_interactive_fullscreen.dart';
import 'package:video_interactive/widget/chewie/src/utils.dart';
import 'package:video_interactive/widget/theme.dart';
import 'package:video_interactive/widget/video/material_progress_bar.dart';
import 'package:video_player/video_player.dart';

typedef Widget KriyaRoutePageBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    KriyaPlayerControllerProvider controllerProvider);

class KriyaPlayer extends StatefulWidget {

  final VideoPlayerBloc videoBloc;
  final bool fullscreen;
  final From from;
  final Function onSkipTrailer;

  KriyaPlayer({
    Key key,
    @required this.videoBloc,
    @required this.fullscreen,
    @required this.from,
    this.onSkipTrailer
  }) :  assert(videoBloc != null, "You must provide the video bloc"),
        assert(fullscreen != null, "You must provide the fullscreen"),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VidPlayerPage();
  }
}

class _VidPlayerPage extends State<KriyaPlayer> with SingleTickerProviderStateMixin {

  bool _isFullScreen = false;
  InteractiveBloc _interactiveBloc;

  @override
  void initState() {
    super.initState();

    print("_VidPlayerPage ${widget.fullscreen}");

    if (widget.videoBloc.interactive) {
      _interactiveBloc = BlocProvider.of<InteractiveBloc>(context);
    } else {
      _interactiveBloc = null;
    }
  }

  void isFullScreen() async {
    await pushFullScreenWidget(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KriyaPlayerControllerProvider(
      videoPlayerBloc: widget.videoBloc, 
      child: PlayerWithControls(
        videoPlayerBloc: widget.videoBloc,
        from: widget.from,
        onSkipTrailer: widget.onSkipTrailer,
        setFullScreen: () async {
          widget.videoBloc..add(VideoFullscreenClickEvent());
          if (widget.videoBloc.interactive) {
            _isFullScreen = widget.fullscreen;
            _isFullScreen = !_isFullScreen;
            _interactiveBloc..add(FullscreenSwitchEvent(fullscreen: _isFullScreen));
            if (_isFullScreen) {
              Navigator.push(context, MaterialPageRoute(
                builder: (BuildContext context) {
                  return BlocProvider.value(
                    value: _interactiveBloc,
                    child: NewInteractiveFullscreen(),
                  );
                }
              ));
            }
          } else {
            if (!_isFullScreen) {
              _isFullScreen = true;
              if (widget.fullscreen) {
                await pushPortraitScreenWidget(context);
              } else {
                await pushFullScreenWidget(context);
              }
            } else if (_isFullScreen) {
              Navigator.of(context, rootNavigator: true).pop();
              _isFullScreen = false;
            }
          }
        },
      )
    );
  }

  Widget buildFullScreenVideo(
      BuildContext context,
      Animation<double> animation,
      KriyaPlayerControllerProvider controllerProvider) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        alignment: Alignment.center,
        color: Colors.black,
        child: controllerProvider,
      ),
    );
  }

  AnimatedWidget defaultRoutePageBuilder(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      KriyaPlayerControllerProvider controllerProvider) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        return BlocProvider.value(
          value: _interactiveBloc,
          child: buildFullScreenVideo(context, animation, controllerProvider),
        );
      },
    );
  }

  Widget fullScreenRoutePageBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    var controllerProvider = KriyaPlayerControllerProvider(
      videoPlayerBloc: widget.videoBloc,
      child: PlayerWithControls(
        videoPlayerBloc: widget.videoBloc,
        from: widget.from,
        onSkipTrailer: widget.onSkipTrailer,
        setFullScreen: () async {
          widget.videoBloc..add(VideoFullscreenClickEvent());
          if (!_isFullScreen) {
            _isFullScreen = true;
            if (widget.fullscreen) {
              await pushPortraitScreenWidget(context);
            } else {
              await pushFullScreenWidget(context);
            }
          } else if (_isFullScreen) {
            Navigator.of(context, rootNavigator: true).pop();
            _isFullScreen = false;
          }
        }
      ),
    );

    return defaultRoutePageBuilder(context, animation, secondaryAnimation, controllerProvider);
  }

  Future<dynamic> pushPortraitScreenWidget(BuildContext context) async {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final TransitionRoute<Null> route = PageRouteBuilder<Null>(
      pageBuilder: fullScreenRoutePageBuilder,
    );
    
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await Navigator.of(context, rootNavigator: true).push(route);
    _isFullScreen = false;

    SystemChrome.setEnabledSystemUIOverlays([]);
    if (isAndroid) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  Future<dynamic> pushFullScreenWidget(BuildContext context) async {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final TransitionRoute<Null> route = PageRouteBuilder<Null>(
      pageBuilder: fullScreenRoutePageBuilder,
    );

    SystemChrome.setEnabledSystemUIOverlays([]);
    if (isAndroid) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    await Navigator.of(context, rootNavigator: true).push(route);
    // _isFullScreen = false;
    // widget.controller.exitFullScreen();

    // The wakelock plugins checks whether it needs to perform an action internally,
    // so we do not need to check Wakelock.isEnabled.
    // Wakelock.disable();

    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

class KriyaPlayerControllerProvider extends InheritedWidget {

  final VideoPlayerBloc videoPlayerBloc;

  const KriyaPlayerControllerProvider({
    Key key,
    @required this.videoPlayerBloc,
    @required Widget child
  }) :  assert(videoPlayerBloc != null),
        assert(child != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(KriyaPlayerControllerProvider oldWidget) {
    return videoPlayerBloc != oldWidget.videoPlayerBloc;
  }

}

class PlayerWithControls extends StatelessWidget {

  final VideoPlayerBloc videoPlayerBloc;
  final Function setFullScreen;
  final From from;
  final Function onSkipTrailer;
  InteractiveBloc _interactiveBloc;
  GlobalKey arKey = new GlobalKey();

  double vidWidth = 0.0;
  double vidHeight = 0.0;

  PlayerWithControls({ 
    Key key, 
    @required this.videoPlayerBloc, 
    @required this.setFullScreen,
    @required this.from,
    this.onSkipTrailer,
  }) :  assert(videoPlayerBloc != null, "Please provide video player bloc"),
        assert(setFullScreen != null, "Please provide on tap function"),
        super(key: key);

  void getAspectRatioHeight() {
    RenderBox box = arKey.currentContext.findRenderObject();
    vidHeight = box.size.height;
    vidWidth = box.size.width;
  }

  void videoDoubleClick(String mode) async {
    switch (mode) {
      case 'forward':
        videoPlayerBloc..add(VideoForwardEvent());
        break;
      case 'rewind':
        videoPlayerBloc..add(VideoRewindEvent());
        break;
    }

    Future.delayed(Duration(milliseconds: 500), () {
      switch (mode) {
        case 'forward':
          videoPlayerBloc..add(VideoForwardBlockOffEvent());
          break;
        case 'rewind':
          videoPlayerBloc..add(VideoRewindBlockOffEvent());
          break;
      }
    });
  }

  playVideo() async {
    videoPlayerBloc..add(VideoPlayEvent());
  }

  stopVideo() async {
    videoPlayerBloc..add(VideoPauseEvent());
  }

  videoOnClick() {
    videoPlayerBloc..add(VideoOnClickEvent());
  }

  onVideoEnd() {
    videoPlayerBloc..add(VideoOnEndEvent());
  }

  onFullScreenClicked() {
    videoPlayerBloc..add(VideoFullscreenClickEvent());
  }

  @override
  Widget build(BuildContext context) {
    if (videoPlayerBloc.interactive) {
      _interactiveBloc = BlocProvider.of<InteractiveBloc>(context);
    }

    return BlocListener<VideoPlayerBloc, VideoPlayerState>(
      bloc: videoPlayerBloc,
      listener: (context, state) {
        if (state is VideoInitializedState) {
          if (state.end) {
            if (videoPlayerBloc.interactive) {
              if (!state.lastVideo) {
                _interactiveBloc..add(NextVideoInteractiveEvent(interactive: state.interactive));
              }
            }
          }
        }
      },
      child: BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
        bloc: videoPlayerBloc,
        builder: (BuildContext context, VideoPlayerState state) {
          if (state is VideoInitializedState) {
            if (videoPlayerBloc.interactive) {
              return videoPlayerInteractivePortrait(context, state);
            } else {
              if (from == From.SUBSCREEN) {
                return videPlayerSubscreenFs(context, state);
              } else if (from == From.MY_COURSES) {
                return videoPlayerMinimalist(context, state);
              } else {
                if (state.fullscreen) {
                  return videoPlayer(context, state);
                } else {
                  return videoPlayerPortrait(context, state);
                }
              }
            }
          }
          return circleProgressBuffering();
        },
      ),
    );
  }

  Widget videoPlayerInteractivePortrait(BuildContext context, VideoInitializedState state) {
    if (state.videoPlayerController.value.initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getAspectRatioHeight();
      });
    }
    if (state.videoPlayerController.value.initialized) {
      return AspectRatio(
        key: arKey,
        aspectRatio: 16/9,
        child: Stack(
          children: <Widget>[
            VideoPlayer(state.videoPlayerController),
            IgnorePointer(
              ignoring: !state.show,
              child: AnimatedOpacity(
                opacity: state.show ? 1 : 0,
                duration: Duration(milliseconds: 500),
                child: Stack(
                  children: <Widget>[
                    fadedBlack(),
                    !state.lastVideo ?
                      state.videoPlayerController.value.isPlaying ?
                      pauseButton()
                          :
                      playButton(state)
                    : restartButton(state),
                    fullscreenButton(),
                    timeDuration(state)
                  ],
                ),
              ),
            ),
            moveForward(context),
            forwardWidget(state, context),
            moveRewind(context),
            rewindWidget(state, context),
            progressBarBuffering(state, context),
            progressBarDuration(state, context),
            videoPlayerBloc.interactive
            ? Stack(
              children: state.interactive.hotspots.map(
                (area) => state.position.inMilliseconds >= area.milisecond
                ? Positioned(
                    top: vidHeight * area.top / 100,
                    left: vidWidth * area.left / 100,
                    child: Container(
                      height: vidHeight * area.height / 100,
                      width: vidWidth * area.width / 100,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(196, 194, 194, 0.6),
                        // borderRadius: BorderRadius.circular(area.borderRadius)
                      ),
                      child: InkWell(
                        onTap: () {
                          _interactiveBloc..add(OnClickHotspotEvent(hotspot: area));
                        },
                      ),
                    ),
                  )
                : Container()
              ).toList(),
            )
            : Container(),
            state.buffer
            ? CircularProgressIndicator() : Container()
          ],
        ),
      );
    }
    return Container();
  }

  Widget restartButton(VideoInitializedState state) {
    return Container(
      height: vidHeight,
      child: Center(
        child: GestureDetector(
          onTap: () {
            _interactiveBloc..add(NextVideoInteractiveEvent(interactive: state.interactive));
            // interactiveVideoBloc..add(RestartVideoEvent());
          },
          child: SvgPicture.asset("lib/assets/icons/play.svg")
        ),
      ),
    );
  }

  Widget videoPlayerMinimalist(BuildContext context, VideoInitializedState state) {
    if (state.videoPlayerController.value.initialized) {
      return AspectRatio(
        aspectRatio: state.videoPlayerController.value.aspectRatio,
        child: VideoPlayer(state.videoPlayerController),
      );
    }
    return Container();
  }

  Widget videoPlayerPortrait(BuildContext context, VideoInitializedState state) {
    if (state.videoPlayerController.value.initialized) {
      return AspectRatio(
        aspectRatio: state.videoPlayerController.value.aspectRatio,
        child: Stack(
          children: <Widget>[
            VideoPlayer(state.videoPlayerController),
            state.first
              ?
            Stack(
              children: <Widget>[
                playButton(state),
                fullscreenButton(),
                timeDuration(state)
              ],
            )
                : Container(),
            IgnorePointer(
              ignoring: !state.show,
              child: AnimatedOpacity(
                opacity: state.show ? 1 : 0,
                duration: Duration(milliseconds: 500),
                child: Stack(
                  children: <Widget>[
                    fadedBlack(),
                    state.videoPlayerController.value.isPlaying ?
                    pauseButton()
                        :
                    playButton(state),
                    fullscreenButton(),
                    timeDuration(state)
                  ],
                ),
              ),
            ),
            moveForward(context),
            forwardWidget(state, context),
            moveRewind(context),
            rewindWidget(state, context),
            progressBarBuffering(state, context),
            progressBarDuration(state, context),
            videoPlayerBloc.interactive
            ? Stack(
              children: state.interactive.hotspots.map(
                (area) => state.position.inMilliseconds >= area.milisecond
                ? Positioned(
                    top: vidHeight * area.top / 100,
                    left: vidWidth * area.left / 100,
                    child: Container(
                      height: vidHeight * area.height / 100,
                      width: vidWidth * area.width / 100,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(196, 194, 194, 0.2),
                        // borderRadius: BorderRadius.circular(area.borderRadius)
                      ),
                      child: InkWell(
                        onTap: () {
                          // interactiveVideoBloc..add(OnClickHotspotEvent(nextVideo: area.nextObj));
                        },
                      ),
                    ),
                  )
                : Container()
              ).toList(),
            )
            : Container()
          ],
        ),
      );
    }
    return Container();
  }

  Widget videPlayerSubscreenFs(BuildContext context, VideoInitializedState state) {
    return GestureDetector(
      onTap: () {
        videoOnClick();
      },
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black,
          child: AspectRatio(
            aspectRatio: state.videoPlayerController.value.aspectRatio,
            child: Container(
              child: Stack(
                children: <Widget>[
                  Center(
                    child: AspectRatio(
                      aspectRatio: state.videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(state.videoPlayerController),
                    ),
                  ),
                  IgnorePointer(
                    ignoring: !state.show,
                    child: AnimatedOpacity(
                      opacity: state.show ? 1 : 0,
                      duration: Duration(milliseconds: 500),
                      child: Stack(
                        children: <Widget>[
                          fadedBlack(),
                          _buildBottomBar(context, state)
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50.0,
                    right: 0.0,
                    child: _buildSkipTrailer(state),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container _buildBottomBar(
    BuildContext context,
    VideoInitializedState state
  ) {
    final iconColor = Theme.of(context).textTheme.button.color;

    return Container(
      color: Color.fromRGBO(0, 0, 0, 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
            child: Text(
              state.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w500
              ),
              textAlign: TextAlign.left,
            ),
          ),
          _buildPlayPause(state),
          Container(
            height: 48.0,
            child: Row(
            children: <Widget>[
                // _buildPlayPause(controller),
                _buildPositionStart(state),
                _buildProgressBar(),
                _buildPositionEnd(state),
                // chewieController.allowMuting ? _buildMuteButton(controller) : Container(),
                _buildExpandButton()
              ],
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector _buildExpandButton() {
    return GestureDetector(
      onTap: setFullScreen,
      child: Container(
        height: 48.0,
        margin: EdgeInsets.only(right: 10.0),
        padding: EdgeInsets.only(
          left: 8.0,
          right: 8.0,
        ),
        child: Center(
          child: Icon(
            Icons.fullscreen,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: MaterialVideoProgressBar(),
      ),
    );
  }

  Widget _buildPositionStart(VideoInitializedState state) {
    final position = state.videoPlayerController.value.position;
    final duration = state.videoPlayerController.value.duration;

    return Padding(
      padding: EdgeInsets.only(left: 20.0),
      child: Text(
        '${formatDuration(position)}',
        style: TextStyle(
          fontSize: 14.0,
          color: Colors.white
        ),
      ),
    );
  }

  Widget _buildPositionEnd(VideoInitializedState state) {
    final position = state.videoPlayerController.value.position;
    final duration = state.videoPlayerController.value.duration;
    final minusDuration = duration - position;

    return Padding(
      padding: EdgeInsets.only(right: 0.0),
      child: Text(
        '- ${formatDuration(minusDuration)}',
        style: TextStyle(
          fontSize: 14.0,
          color: Colors.white
        ),
      ),
    );
  }

  Expanded _buildPlayPause(VideoInitializedState state) {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: (){
            if (state.videoPlayerController.value.isPlaying) {
              stopVideo();
            } else {
              playVideo();
            }
          },
          child: state.videoPlayerController.value.isPlaying ? SvgPicture.asset("lib/assets/icons/pause.svg") : SvgPicture.asset("lib/assets/icons/play.svg"),
        ),
      ),
    );
  }

  Widget _buildSkipTrailer(VideoInitializedState state) {
    final position = state.videoPlayerController.value.position;
    final duration = state.videoPlayerController.value.duration;

    final minusDuration = Duration(seconds: 5) - position;
    var text = "";
    bool ready = false;
    if (minusDuration < Duration(seconds: 1)) {
      text = "Skip Trailer";
      ready = true;
    } else {
      text = minusDuration.inSeconds.toString();
      ready = false;
    }

    return GestureDetector(
      onTap: () {
        if (ready) {
          onSkipTrailer();
        }
      },
      child: Container(
        height: 40,
        child: Container(
          color: Color.fromRGBO(0, 0, 0, 0.9),
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Row(
              children: <Widget>[
                Text(
                  "$text",
                  style: TextStyle(
                    color: Color(0xff2F8CB2),
                  ),
                ),
                SizedBox(width: 5),
                SvgPicture.asset("lib/assets/icons/next_skip.svg")
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget videoPlayer(BuildContext context, VideoInitializedState state) {
    if (state.videoPlayerController.value.initialized) {
      return Stack(
        children: <Widget>[
          Center(
            child: AspectRatio(
              aspectRatio: state.videoPlayerController.value.aspectRatio,
              child: VideoPlayer(state.videoPlayerController),
            ),
          ),
          state.first
              ? Stack(
                  children: <Widget>[
                    playButton(state),
                    fullscreenButton(),
                    timeDuration(state)
                  ],
                )
              : Container(),
          IgnorePointer(
            ignoring: !state.show,
            child: AnimatedOpacity(
              opacity: state.show ? 1 : 0,
              duration: Duration(milliseconds: 500),
              child: Stack(
                children: <Widget>[
                  fadedBlack(),
                  state.videoPlayerController.value.isPlaying ?
                  pauseButton()
                      :
                  playButton(state),
                  fullscreenButton(),
                  timeDuration(state)
                ],
              ),
            ),
          ),
          moveForward(context),
          forwardWidget(state, context),
          moveRewind(context),
          rewindWidget(state, context),
          progressBarBuffering(state, context),
          progressBarDuration(state, context),
        ],
      );
    }
    return Container();
  }

  Widget circleProgressBuffering() {
    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: 250
      ),
      child: Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.white,
            strokeWidth: 1,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        ),
      ),
    );
  }

  Widget playButton(VideoInitializedState state) {
    return Center(
      child: InkWell(
          onTap: () {
            if (videoPlayerBloc.interactive) {
              if (!state.lastVideo && !state.end) {
                playVideo();
              }
            } else {
              playVideo();
            }
          },
          child: SvgPicture.asset("lib/assets/icons/play.svg")
      ),
    );
  }

  Widget pauseButton() {
    return  Center(
      child: InkWell(
          onTap: () {
            stopVideo();
          },
          child: SvgPicture.asset("lib/assets/icons/pause.svg")
      ),
    );
  }

  Widget fadedBlack() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: KriyaColor().black06,
      ),
    );
  }

  Widget fullscreenButton() {
    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100.0)
        ),
        child: InkWell(
          onTap: setFullScreen,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                "lib/assets/icons/full_screen_new.svg",
                width: 14,
                height: 14,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget timeDuration(VideoInitializedState state) {
    if (state.first) {
      return Positioned(
          left: 20,
          bottom: 20,
          child: Container(
            width: 44,
            height: 17,
            decoration: BoxDecoration(
              color: KriyaColor().gray063,
              borderRadius:
              BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Text(
                "${state.minutes.toString().padLeft(2, '0')} : ${state.seconds.toString().padLeft(2, '0')}",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    color: Colors.white),
              ),
            ),
          )
      );
    } else {
      return Positioned(
          left: 20,
          bottom: 20,
          child: Container(
            width: 44,
            height: 17,
            decoration: BoxDecoration(
              color: KriyaColor().gray063,
              borderRadius:
              BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Text(
                "${state.currentMinutes.toString().padLeft(2, '0')} : ${state.currentSeconds.toString().padLeft(2, '0')}",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    color: Colors.white),
              ),
            ),
          )
      );
    }
  }

  Widget progressBarBuffering(VideoInitializedState state, BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 2,
        width: MediaQuery.of(context).size.width,
        child: LinearProgressIndicator(
          value: state.videoPlayerController.value.buffered.length == 0 
          ? 0 : state.videoPlayerController.value.buffered[0].end.inSeconds / state.videoPlayerController.value.duration.inSeconds,
          backgroundColor: KriyaColor().graysE5E5E5,
          valueColor: AlwaysStoppedAnimation<Color>(KriyaColor().grays484848),
        ),
      ),
    );
  }

  Widget progressBarDuration(VideoInitializedState state, BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 2,
        width: MediaQuery.of(context).size.width,
        child: LinearProgressIndicator(
          value: state.videoPlayerController.value.position.inSeconds / state.videoPlayerController.value.duration.inSeconds,
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.2),
          // backgroundColor: KriyaColor().graysE5E5E5,
          valueColor: AlwaysStoppedAnimation<Color>(KriyaColor().kriyaLabD02D91),
        ),
      ),
    );
  }

  Widget moveForward(BuildContext context) {
    return Positioned(
      bottom: 45,
      right: 0,
      top: 0,
      width: MediaQuery.of(context).size.width / 2.5,
      child: InkWell(
        onDoubleTap: () {
          videoDoubleClick("forward");
        },
        onTap: () {
          videoOnClick();
        },
        child: IgnorePointer(
            ignoring: true, child: Container()),
      ),
    );
  }

  Widget forwardWidget(VideoInitializedState state, BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      top: 0,
      width: MediaQuery.of(context).size.width / 2.5,
      child: IgnorePointer(
        ignoring: true,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 200),
          opacity: state.forward ? 1 : 0,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              "10 Second",
              style: TextStyle(color: Colors.grey),
            ),
            decoration: BoxDecoration(
              color: KriyaColor().black06,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100.0),
                  topLeft: Radius.circular(100.0)
              )
            ),
          ),
        ),
      ),
    );
  }

  Widget moveRewind(BuildContext context) {
    return Positioned(
      bottom: 45,
      left: 0,
      top: 0,
      width: MediaQuery.of(context).size.width / 2.5,
      child: InkWell(
        onDoubleTap: () {
          videoDoubleClick("rewind");
        },
        onTap: () {
          videoOnClick();
        },
        child: IgnorePointer(
            ignoring: true, child: Container()),
      ),
    );
  }

  Widget rewindWidget(VideoInitializedState state, BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      top: 0,
      width: MediaQuery.of(context).size.width / 2.5,
      child: IgnorePointer(
        ignoring: true,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 200),
          opacity: state.rewind ? 1 : 0,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              "10 Second",
              style: TextStyle(color: Colors.grey),
            ),
            decoration: BoxDecoration(
                color: KriyaColor().black06,
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(100.0),
                    topRight: Radius.circular(100.0))),
          ),
        ),
      ),
    );
  }

}