import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_interactive/bloc/interactive_video_new_bloc.dart';
import 'package:video_interactive/interactive/video_widget.dart';

class VideoPage extends StatefulWidget {
  
  final InteractiveVideoNewBloc interactiveVideoNewBloc;

  VideoPage({ 
    @required this.interactiveVideoNewBloc,
  });

  @override
  State<StatefulWidget> createState() {
    return _VideoPage();
  }

}

class _VideoPage extends State<VideoPage> {
  
  Future<bool> _onWillPopScope() async {
    widget.interactiveVideoNewBloc..add(FullscreenVideoEvent(context: context, interactiveVideoNewBloc: widget.interactiveVideoNewBloc));
    // print("asdjawjdlajwdliawd popscope");
    // Navigator.of(context).pop(true);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: BlocBuilder<InteractiveVideoNewBloc, InteractiveVideoState>(
        bloc: widget.interactiveVideoNewBloc,
        builder: (context, state) {
          if (state is InitializedInteractiveVideoState) {
            return Scaffold(
              body: Container(
                child: Hero(
                  tag: "video_interactive",
                  child: VideoWidget(interactiveVideoNewBloc: widget.interactiveVideoNewBloc),
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