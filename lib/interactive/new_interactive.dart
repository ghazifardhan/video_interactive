import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_interactive/bloc/from.dart';
import 'package:video_interactive/bloc/interactive_bloc.dart';
import 'package:video_interactive/bloc/video_player/video_player_bloc.dart';
import 'package:video_interactive/bloc/video_player/video_player_event.dart';
import 'package:video_interactive/widget/video/kriya_video.dart';

class NewInteractive extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewInteractiveState();
  }
}

class _NewInteractiveState extends State<NewInteractive> {

  List<String> _videoUrls = new List<String>();
  int _playingIndex = 0;
  InteractiveBloc _interactiveBloc;

  @override
  void initState() {
    super.initState();

    _interactiveBloc = new InteractiveBloc();
    _interactiveBloc..add(LoadInteractiveEvent());


    // make portrait again
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _interactiveBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("New Interactive")
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            BlocProvider<InteractiveBloc>(
              create: (context) => _interactiveBloc,
              child: BlocListener<InteractiveBloc, InteractiveBlocState>(
                listener: (context, state) {
                },
                child: BlocBuilder<InteractiveBloc, InteractiveBlocState>(
                  builder: (context, state) {
                    print(state);
                    if (state is InteractiveInitializedState) {
                      return KriyaPlayer(
                        key: Key("mantap gan ${state.playingIndex}"),
                        videoBloc: state.videoPlayerBloc, 
                        fullscreen: state.fullscreen, 
                        from: From.LESSON_PAGE
                      );
                    }
                    return Container(child: Text("Video Uninitialize"),);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}