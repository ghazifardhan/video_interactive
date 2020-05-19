import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queue/queue.dart';
import 'package:video_interactive/bloc/from.dart';
import 'package:video_interactive/bloc/interactive_bloc_v2.dart';
import 'package:video_interactive/model/interactive_new_model.dart';
import 'package:video_interactive/widget/video/kriya_video.dart';
import 'package:video_interactive/widget/video/kriya_video_v2.dart';

class NewInteractiveV2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewInteractiveState();
  }
}

class _NewInteractiveState extends State<NewInteractiveV2> {

  List<String> _videoUrls = new List<String>();
  int _playingIndex = 0;
  InteractiveBlocV2 _interactiveBloc;

  StreamController _getVideos;

  @override
  void initState() {
    super.initState();
    init();
    
    

    // make portrait again
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  init() async {
    _getVideos = new StreamController();
    InteractiveNewModel datas = await getVideos();

    _interactiveBloc = new InteractiveBlocV2();
    _interactiveBloc..add(LoadInteractiveEvent(
      assets: datas.assets, 
      from: "lesson", 
      interactives: datas.blocks[0].content.interactive
    ));

    print("getInteractiveVideos ${datas.id}");
    Future.delayed(Duration(seconds: 2), () {
      _getVideos.add(datas);
    });
  }

  Future<InteractiveNewModel> getVideos() async {
    return await rootBundle.loadString("lib/json/list_video_all.json")
        .then((String data) => InteractiveNewModel.fromJson(json.decode(data)));
  }

  test() async {
    //Create the queue container
    final Queue queue = Queue(delay: Duration(milliseconds: 10));
    
    //Add items to the queue asyncroniously
    queue.add(() => Future.delayed(Duration(milliseconds: 100), () { print(100); }) );
    queue.add(() => Future.delayed(Duration(milliseconds: 10), () { print(10); }));
    
    //Get a result from the future in line with await
    final result = await queue.add(() async {
      await Future.delayed(Duration(milliseconds: 1));
      return "Future Complete";
    });
    
    //100, 10, 1 will reslove in that order.
    // result == "Future Complete";
    print(result);
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
            StreamBuilder(
              stream: _getVideos.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  InteractiveNewModel model = snapshot.data;
                  print(model.id);
                  return BlocProvider<InteractiveBlocV2>(
                    create: (context) => _interactiveBloc,
                    child: BlocListener<InteractiveBlocV2, InteractiveBlocV2State>(
                      listener: (context, state) {
                      },
                      child: BlocBuilder<InteractiveBlocV2, InteractiveBlocV2State>(
                        builder: (context, state) {
                          print(state);
                          if (state is InteractiveInitializedState) {
                            return KriyaPlayerV2(
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
                  );
                }
                return CircularProgressIndicator();
              },
            ),
            
          ],
        ),
      ),
    );
  }

}