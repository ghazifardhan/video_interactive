import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_interactive/bloc/interactive_video_new_bloc.dart';
import 'package:video_interactive/bloc/video_bloc.dart';
import 'package:video_interactive/interactive/video_widget.dart';
import 'package:video_interactive/model/interactive_model.dart';
import 'package:video_player/video_player.dart';

class NewVideo extends StatefulWidget {

  final String from;

  NewVideo({ @required this.from });

  @override
  State<StatefulWidget> createState() {
    return _VideoPage();
  }

}

class _VideoPage extends State<NewVideo> {

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
    _interactiveVideoNewBloc = InteractiveVideoNewBloc()..add(InitializeInteractiveVideoEvent(from: widget.from));
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
    _interactiveVideoNewBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: new AppBar(
        title: Text("Video Interactive"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            BlocProvider<InteractiveVideoNewBloc>(
              create: (BuildContext context) => _interactiveVideoNewBloc,
              child: Hero(
                tag: "video_interactive",
                child: VideoWidget(interactiveVideoNewBloc: _interactiveVideoNewBloc),
              ),
            )
          ],
        )
      )
    );
  }

}