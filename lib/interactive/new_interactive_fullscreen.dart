import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_interactive/bloc/from.dart';
import 'package:video_interactive/bloc/interactive_bloc_v2.dart';
import 'package:video_interactive/widget/video/kriya_video.dart';
import 'package:video_interactive/widget/video/kriya_video_v2.dart';

class NewInteractiveFullscreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewInteractiveFullscreenState();
  }

}

class _NewInteractiveFullscreenState extends State<NewInteractiveFullscreen> {

  InteractiveBlocV2 _interactiveBloc;

  @override
  void initState() {
    super.initState();

    _interactiveBloc = BlocProvider.of<InteractiveBlocV2>(context);

    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // make portrait again
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocListener<InteractiveBlocV2, InteractiveBlocV2State>(
      listener: (context, state) {
        if (state is InteractiveInitializedState) {
          print("state.fullscreen ${state.fullscreen}");
          if (!state.fullscreen) {
            Navigator.pop(context);
          }
        }
      },
      child: BlocBuilder<InteractiveBlocV2, InteractiveBlocV2State>(
        builder: (context, state) {
          if (state is InteractiveInitializedState) {
            return Scaffold(
              resizeToAvoidBottomPadding: true,
              body: Container(
                alignment: Alignment.center,
                color: Colors.black,
                child: KriyaPlayerV2(
                  key: Key("mantap gan ${state.playingIndex}"),
                  videoBloc: state.videoPlayerBloc, 
                  fullscreen: state.fullscreen, 
                  from: From.LESSON_PAGE
                ),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

}