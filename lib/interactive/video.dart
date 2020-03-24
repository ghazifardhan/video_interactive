import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_interactive/bloc/interactive_video_bloc.dart';
import 'package:video_interactive/bloc/video_bloc.dart';
import 'package:video_interactive/model/interactive_model.dart';
import 'package:video_player/video_player.dart';

class Video extends StatefulWidget {

  final String from;

  Video({ @required this.from });

  @override
  State<StatefulWidget> createState() {
    return _VideoPage();
  }

}

class _VideoPage extends State<Video> {

  InteractiveVideoBloc _interactiveVideoBloc;
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
    _interactiveVideoBloc = InteractiveVideoBloc()..add(InitializeInteractiveVideoEvent(from: widget.from));
  }

  Future<InteractiveModel> getVideos() async {
    return await rootBundle.loadString("lib/json/video.json")
        .then((String data) => InteractiveModel.fromJson(json.decode(data)));
  }

  void getAspectRatioHeight() {
    RenderBox box = arKey.currentContext.findRenderObject();
    setState(() {
      vidHeight = box.size.height;
      vidWidth = box.size.width;
    });
  }

  @override
  void dispose() {
    _interactiveVideoBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocProvider<InteractiveVideoBloc>(
          create: (BuildContext context) => _interactiveVideoBloc,
          child: BlocBuilder<InteractiveVideoBloc, InteractiveVideoState>(
            builder: (context, state) {
              if (state is InitializedInteractiveVideoState) {
                if (state.fullscreen) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    SystemChrome.setEnabledSystemUIOverlays([]);
                    SystemChrome.setPreferredOrientations(
                        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
                  });
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    SystemChrome.setPreferredOrientations(
                        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
                  });
                }

                return FutureBuilder(
                  future: state.initializePlayers,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return videoWidgetNew(state);
                    }
                    return CircularProgressIndicator();
                  },
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  Widget videoWidgetNew(InitializedInteractiveVideoState state) {
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
                state.model.data[state.playingIndex].hotspot
                ? Stack(
                  children: state.model.data[state.playingIndex].area.map((area) =>
                      Positioned(
                        top: vidHeight * area.y / 100,
                        left: vidWidth * area.x / 100,
                        child: Container(
                          height: vidWidth * area.height / 100,
                          width: vidWidth * area.width / 100,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(196, 194, 194, 0.2),
                            borderRadius: BorderRadius.circular(area.borderRadius)
                          ),
                          child: InkWell(
                            onTap: () {
                              _interactiveVideoBloc..add(OnClickHotspotEvent(nextVideo: area.nextVideos));
                            },
                          ),
                        ),
                      )
                  ).toList(),
                )
                : Container()
              ],
            ),
          ),
        ),
        Positioned(
            bottom: 20.0,
            right: 20.0,
            child: IconButton(
              icon: Icon(CupertinoIcons.play_arrow_solid, size: 25.0,
                color: Colors.white,),
              onPressed: () {
                print("play ${state.playingIndex}");
                _interactiveVideoBloc..add(PlayInteractiveVideoEvent(index: state.playingIndex));
              },
            )
        ),
        Positioned(
            bottom: 20.0,
            left: 20.0,
            child: IconButton(
              icon: Icon(
                CupertinoIcons.pause_solid, size: 25.0, color: Colors.white,),
              onPressed: () {
                _interactiveVideoBloc..add(StopInteractiveVideoEvent(index: state.playingIndex));
              },
            )
        ),
        Positioned(
            bottom: 60.0,
            left: 20.0,
            child: IconButton(
              icon: Icon(
                CupertinoIcons.fullscreen, size: 25.0, color: Colors.white,),
              onPressed: () {
                _interactiveVideoBloc..add(FullscreenVideoEvent());
              },
            )
        ),
        Positioned(
          left: 20.0,
          top: 20.0,
          child: Text(
            "Position: ${state.playingIndex}",
            style: TextStyle(
              color: Colors.blue
            ),
          ),
        )
      ],
    );
  }

}