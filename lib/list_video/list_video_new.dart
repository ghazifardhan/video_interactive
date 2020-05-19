import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:video_interactive/bloc/from.dart';
import 'package:video_interactive/bloc/video_bloc.dart';
import 'package:video_interactive/bloc/video_player/video_player_bloc.dart';
import 'package:video_interactive/bloc/video_player/video_player_event.dart';
import 'package:video_interactive/widget/video/kriya_video.dart';
import 'package:video_player/video_player.dart';

class ListVideoNew extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ListVideoNewState();
  }

}

class VideoModel {
  GlobalKey<_MyContainerPage> key;
  String url;
  String name;

  VideoModel({ 
    @required this.key,
    @required this.url,
    @required this.name
  });
}

class _ListVideoNewState extends State<ListVideoNew> {
  
  VideoPlayerController _controller;
  bool _disposed = false;
  bool _ready = false;
  List<VideoModel> myKey;
  ScrollController _scrollController;
  bool loading = true;

  VideoPlayerBloc _videoPlayerBloc;

  @override
  void initState() {
    super.initState();

    
    init();
  }

  init() async {

    _initController("https://kriyapeople.s3-ap-southeast-1.amazonaws.com/interactive+video/INTERACTIVE+PROTOTIPE/vr/Vi1.mp4");

    myKey = new List<VideoModel>();
    myKey = await setGlobalKey();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        loading = false;
        _scrollController = new ScrollController();
        _scrollController.addListener(scrollController);
      });
    });
  }

  Future<List<VideoModel>> setGlobalKey() async {
    List<VideoModel> keys = new List<VideoModel>();
    for (int i = 0; i < 5; i++) {
      keys.add(VideoModel(
        key: GlobalKey<_MyContainerPage>(), 
        url: "https://r5---sn-npoe7ned.googlevideo.com/videoplayback?expire=1586719816&ei=6BeTXrbAHPSCobIPyfqgqAI&ip=45.175.174.125&id=o-AB9p5Xe2NuYl3mhfvePCxWvSoB39trEO2i4dBLDlpiVX&itag=18&source=youtube&requiressl=yes&vprv=1&mime=video%2Fmp4&gir=yes&clen=14878273&ratebypass=yes&dur=293.221&lmt=1580264975242268&fvip=5&c=WEB&txp=5531432&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cgir%2Cclen%2Cratebypass%2Cdur%2Clmt&sig=AJpPlLswRAIgVbMER60LPc47E0ablmLbnTjzNIkdLWblUbPZ2Pqi-n8CIB1-hYTDJfY3COggcTSgBpcwMM1ERO_m7ovf9n4rc2Pq&video_id=S0kaqFBoGqI&title=GuyonWaton+Official+-+Korban+Janji+%28Official+Music+Video%29&rm=sn-8p5hvj-hvjl7l,sn-bg0kl76&req_id=3504a29a86e3a3ee&redirect_counter=2&cms_redirect=yes&ipbypass=yes&mh=Vj&mip=202.80.215.187&mm=29&mn=sn-npoe7ned&ms=rdu&mt=1586706760&mv=m&mvi=4&pl=24&lsparams=ipbypass,mh,mip,mm,mn,ms,mv,mvi,pl&lsig=ALrAebAwRQIgJelzfGGoLZPv1WNaYnAMOQg_hcmDg3PWLz1tpOcFlewCIQD1zkRo3x66zmkseLvjqHmDq1-Z2YKvYzG_1iTxTDXfNA%3D%3D", 
        name: "Guyon Waton $i"
      ));
    }
    return keys;
  }

  // initVideo() {
  //   _controller = VideoPlayerController.network("https://r1---sn-npoe7ney.googlevideo.com/videoplayback?expire=1586529488&ei=bzCQXqjFOqCWz7sP6su88AM&ip=125.24.172.195&id=o-ABA72hM3D573VTcJhubtpQfhEBd1AP1Z0d_tQTcT3BDF&itag=18&source=youtube&requiressl=yes&vprv=1&mime=video%2Fmp4&gir=yes&clen=13499453&ratebypass=yes&dur=232.663&lmt=1575005310261006&fvip=1&fexp=23882514&c=WEB&txp=5531432&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cgir%2Cclen%2Cratebypass%2Cdur%2Clmt&sig=AJpPlLswRgIhAP-piEF9yAk0GKdpMF2hPzbZ30QWZ5Y_RfGdufHaGZ0-AiEAtnMhl-vlIOrMbzAmpFi0fT-YGTfFQWni9jMyGu7gTT4%3D&video_id=tB48sKGi5ag&title=PUBLIC+-+Make+You+Mine+%28Official+Lyric+Video%29&rm=sn-uvu-c33ez7r,sn-30all7d&req_id=eb5f01bc3e0aa3ee&redirect_counter=2&cms_redirect=yes&ipbypass=yes&mh=H2&mip=202.80.215.187&mm=30&mn=sn-npoe7ney&ms=nxu&mt=1586513905&mv=m&mvi=0&pl=24&lsparams=ipbypass,mh,mip,mm,mn,ms,mv,mvi,pl&lsig=ALrAebAwRgIhANsHLDR3rXQygER5B-E2u1wuo-08zsO5j9y-JDCvr4NpAiEA0uyyOAt2V7i-1ee9hgToJUbLkED0DIs-X8LT6fkCnfU%3D");
  //   _controller.initialize().then((_) {
  //     setState(() {
  //       _ready = true;
  //     });
  //     // _controller.play();
  //   });
  // }

  void _initController(String link) {
    _videoPlayerBloc = VideoPlayerBloc(url: link, from: From.LESSON_PAGE);
    _videoPlayerBloc..add(VideoInitializeEvent(autoPlay: false, fullscreen: false));
  }

  Future<void> _onControllerChange(String link) async {
    if (_videoPlayerBloc == null) {
      // If there was no controller, just create a new one
      _initController(link);
    } else {
      // If there was a controller, we need to dispose of the old one first
      final _oldVideoPlayerBloc = _videoPlayerBloc;

      // Registering a callback for the end of next frame
      // to dispose of an old controller
      // (which won't be used anymore after calling setState)
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _oldVideoPlayerBloc.close();

        // Initing new controller
        _initController(link);
      });

      // Making sure that controller is not used by setting it to null
      setState(() {
        _videoPlayerBloc = null;
      });
    }
  }


  initDisposed() {
    _controller.dispose();
    setState(() {
      _disposed = true;
    });
  }

  scrollController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
    myKey.forEach((key) {
      double offset = MediaQuery.of(context).size.height / 3;
      RenderBox box = key.key.currentContext.findRenderObject();
      Offset position = box.localToGlobal(Offset.zero);
      double y = position.dy;

      if (y >= 25 && y < offset) { 
        print("${key.name} : $y load");
        _onControllerChange(key.url);
      } else {
        print("${key.name} : $y unload");
      }
    });

    });
    // double offset = MediaQuery.of(context).size.height / 3;
    // RenderBox box = v.key.currentContext.findRenderObject();
    // Offset position = box.localToGlobal(Offset.zero); //
    // double y = position.dy;

    // if (y >= -25 && y < offset) {
    //   // v.currentState.playVideo();
    //   // print("${v.url} ${v.key} load");
    //   _myCoursesBloc..add(ChangeVideoPlayerEvent(playingIndex: k));
    // }
    // else {
    //   // print("${v.url} ${v.key} unload");
    //   // v.currentState.pauseVideo();
    // }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("List of Videos")
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
              color: Color.fromRGBO(0, 0, 0, 0.5),
              height: MediaQuery.of(context).size.height / 3,
              ),
            ),
            loading ? Text("Loading kali gan") :
            ListView.separated(
              controller: _scrollController,
              shrinkWrap: false,
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 20.0);
              },
              itemCount: myKey.length, 
              itemBuilder: (context, index) {
                return KriyaPlayer(
                  key: myKey[index].key,
                  videoBloc: _videoPlayerBloc, 
                  fullscreen: false, 
                  from: From.LESSON_PAGE
                );
                // return KriyaPlayer(
                //   key: Key(index.toString()),
                //   from: From.LESSON_PAGE, 
                //   fullscreen: false, 
                //   videoBloc: VideoPlayerBloc(
                //     url: "https://r1---sn-npoe7ney.googlevideo.com/videoplayback?expire=1586529488&ei=bzCQXqjFOqCWz7sP6su88AM&ip=125.24.172.195&id=o-ABA72hM3D573VTcJhubtpQfhEBd1AP1Z0d_tQTcT3BDF&itag=18&source=youtube&requiressl=yes&vprv=1&mime=video%2Fmp4&gir=yes&clen=13499453&ratebypass=yes&dur=232.663&lmt=1575005310261006&fvip=1&fexp=23882514&c=WEB&txp=5531432&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cgir%2Cclen%2Cratebypass%2Cdur%2Clmt&sig=AJpPlLswRgIhAP-piEF9yAk0GKdpMF2hPzbZ30QWZ5Y_RfGdufHaGZ0-AiEAtnMhl-vlIOrMbzAmpFi0fT-YGTfFQWni9jMyGu7gTT4%3D&video_id=tB48sKGi5ag&title=PUBLIC+-+Make+You+Mine+%28Official+Lyric+Video%29&rm=sn-uvu-c33ez7r,sn-30all7d&req_id=eb5f01bc3e0aa3ee&redirect_counter=2&cms_redirect=yes&ipbypass=yes&mh=H2&mip=202.80.215.187&mm=30&mn=sn-npoe7ney&ms=nxu&mt=1586513905&mv=m&mvi=0&pl=24&lsparams=ipbypass,mh,mip,mm,mn,ms,mv,mvi,pl&lsig=ALrAebAwRgIhANsHLDR3rXQygER5B-E2u1wuo-08zsO5j9y-JDCvr4NpAiEA0uyyOAt2V7i-1ee9hgToJUbLkED0DIs-X8LT6fkCnfU%3D", 
                //     from: From.LESSON_PAGE
                //   )..add(VideoInitializeEvent(fullscreen: false, autoPlay: false)),
                // );
              }, 
            ),
          ],
        ),
      ),
      // body: Container(
      //   child: Column(
      //     children: <Widget>[
      //       _ready
      //         ? AspectRatio(
      //           aspectRatio: _controller.value.size.aspectRatio,
      //           child: VideoPlayer(_controller),
      //         )
      //         : CircularProgressIndicator(),
      //         CupertinoButton(
      //           child: Text("Play"), 
      //           onPressed: () {
      //             initVideo();
      //           }
      //         ),
      //         CupertinoButton(
      //           child: Text("Dispose"), 
      //           onPressed: () {
      //             initDisposed();
      //           }
      //         ),
      //     ],
      //   ),
      // ),
    );
  }

}

class MyContainer extends StatefulWidget {

  MyContainer({ Key key }) : super(key: key);
  
  @override
  State<StatefulWidget> createState() {
    return _MyContainerPage();
  }

}

class _MyContainerPage extends State<MyContainer> {

  String name = "";

  @override
  void initState() {
    super.initState();
  }

  changeName(String name) {
    WidgetsBinding.instance.addPostFrameCallback((_){
      setState(() {
        name = name;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    print("set name ${this.name}");
    return Container(
      height: 180,
      color: Colors.green,
      child: Text(this.name),
    );
  }

}