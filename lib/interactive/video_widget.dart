import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_interactive/bloc/interactive_video_new_bloc.dart';
import 'package:video_interactive/bloc/video_bloc.dart';
import 'package:video_interactive/interactive/video_page.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  
  final InteractiveVideoNewBloc interactiveVideoNewBloc;

  VideoWidget({ @required this.interactiveVideoNewBloc });

  @override
  State<StatefulWidget> createState() {
    return _VideoWidgetPage();
  }

}

class _VideoWidgetPage extends State<VideoWidget> {

  InteractiveVideoNewBloc _interactiveVideoNewBloc;
  List<String> videoUrls = new List<String>();
  List<VideoBloc> _videoBlocs = new List<VideoBloc>();
  GlobalKey arKey = new GlobalKey();

  double vidWidth = 0.0;
  double vidHeight = 0.0;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    // _interactiveVideoNewBloc = BlocProvider.of<InteractiveVideoNewBloc>(context);
    _interactiveVideoNewBloc = widget.interactiveVideoNewBloc;
  }

  void getAspectRatioHeight() {
    RenderBox box = arKey.currentContext.findRenderObject();
    setState(() {
      vidHeight = box.size.height;
      vidWidth = box.size.width;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InteractiveVideoNewBloc, InteractiveVideoState>(
      bloc: _interactiveVideoNewBloc,
      builder: (context, state) {
        if (state is InitializedInteractiveVideoState) {
          if (!state.isBuffering) {
            return FutureBuilder(
              future: state.initializePlayers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return InkWell(
                    onTap: () {
                      _interactiveVideoNewBloc..add(VideoOnClickEvent());
                    },
                    child: videoWidgetNew(state, context),
                  );
                }
                return circleProgressBuffering();
              },
            );
          }
          return circleProgressBuffering();
        }
        return circleProgressBuffering();
      },
    );
  }

  Widget videoWidgetNew(InitializedInteractiveVideoState state, BuildContext context) {
    if (state.videoPlayerController.value.initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getAspectRatioHeight();
      });
    }
    return Stack(
      children: <Widget>[
        Container(
            color: Colors.black
        ),
        Center(
          child: AspectRatio(
            key: arKey,
            aspectRatio: state.videoPlayerController.value.size.aspectRatio,
            child: Stack(
              children: <Widget>[
                VideoPlayer(state.videoPlayerController),
                state.interactive[state.playingIndex].hotspots.length > 0
                ? Stack(
                  children: state.interactive[state.playingIndex].hotspots.map((area) =>
                      state.currentMiliseconds >= area.milisecond ?
                      Positioned(
                        top: vidHeight * area.top / 100,
                        left: vidWidth * area.left / 100,
                        child: Container(
                          height: vidHeight * area.height / 100,
                          width: vidWidth * area.width / 100,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(196, 194, 194, 0.2),
                          ),
                          child: InkWell(
                            onTap: () {
                              _interactiveVideoNewBloc..add(OnClickHotspotEvent(nextVideo: area.nextObj));
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
          ),
        ),
        IgnorePointer(
          ignoring: !state.show,
          child: AnimatedOpacity(
            opacity: state.show ? 1 : 0,
            duration: Duration(milliseconds: 500),
            child: Stack(
              children: <Widget>[
                Container(height: vidHeight),
                fadedBlack(),
                !state.isEndVideo ?
                    state.videoPlayerController.value.isPlaying 
                    ? pauseButton(state)
                    : playButton(state)
                :
                restartButton(state),
                fullscreenButton(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget fadedBlack() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.6),
      ),
    );
  }

  Widget playButton(InitializedInteractiveVideoState state) {
    return Container(
      height: vidHeight,
      child: Center(
        child: InkWell(
            onTap: () {
              print("play ${state.playingIndex}");
              _interactiveVideoNewBloc..add(PlayInteractiveVideoEvent(index: state.playingIndex, first: false));
            },
            child: SvgPicture.asset("lib/assets/icons/play.svg")
        ),
      ),
    );
  }

  Widget pauseButton(InitializedInteractiveVideoState state) {
    return Container(
      height: vidHeight,
      child: Center(
        child: InkWell(
          onTap: () {
            _interactiveVideoNewBloc..add(StopInteractiveVideoEvent(index: state.playingIndex));
          },
          child: SvgPicture.asset("lib/assets/icons/pause.svg")
        ),
      ),
    );
  }

  Widget restartButton(InitializedInteractiveVideoState state) {
    return Container(
      height: vidHeight,
      child: Center(
        child: GestureDetector(
          onTap: () {
            _interactiveVideoNewBloc..add(RestartVideoEvent());
          },
          child: Container(
            width: 50,
            height: 50,
            color: Colors.white,
            child: Icon(Icons.refresh, size: 25, color: Colors.blue,),
          )
        ),
      ),
    );
  }

  Widget fullscreenButton(BuildContext context) {
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
          onTap: () {
            _interactiveVideoNewBloc..add(FullscreenVideoEvent(context: context, interactiveVideoNewBloc: _interactiveVideoNewBloc));
          },
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

  Widget circleProgressBuffering() {
    return Container(
      color: Colors.black,
      height: 200,
      child: Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
          strokeWidth: 1,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      ),
    );
  }
}