import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ChewieTest extends StatefulWidget {
  
  @override
  State<StatefulWidget> createState() {
    return _ChewieTestPage();
  }

}

class _ChewieTestPage extends State<ChewieTest> {

  TargetPlatform _platform;
  VideoPlayerController _videoPlayerController1;
  ChewieController _chewieController;
  Future<void> _future;

  Future<void> initVideoPlayer() async {
    _videoPlayerController1 = VideoPlayerController.network('https://s3-ap-southeast-1.amazonaws.com//kriyapeople/94b52d33-a967-4432-a46f-fb1c9ef6a127');
    await _videoPlayerController1.initialize();
    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController1,
        aspectRatio: _videoPlayerController1.value.size.aspectRatio,
        autoPlay: true,
        looping: true,
        // Try playing around with some of these other options:

        // showControls: false,
        // materialProgressColors: ChewieProgressColors(
        //   playedColor: Colors.red,
        //   handleColor: Colors.blue,
        //   backgroundColor: Colors.grey,
        //   bufferedColor: Colors.lightGreen,
        // ),
        // placeholder: Container(
        //   color: Colors.grey,
        // ),
        // autoInitialize: true,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _future = initVideoPlayer();
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Container(
  //       color: Colors.black,
  //       child: ChewieDetail(videoPlayerController: _videoPlayerController[0]),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    return MaterialApp(
      title: "Chewie",
      theme: ThemeData.light().copyWith(
        platform: _platform ?? Theme.of(context).platform,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Chewie"),
        ),
        body: Column(
          children: <Widget>[
            Center(
              child: FutureBuilder(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return new Container(
                      color: Colors.black,
                      child: ClipRect(
                        child: AspectRatio(
                          aspectRatio: _videoPlayerController1.value.size.aspectRatio,
                          child: Chewie(
                            controller: _chewieController,
                          ),
                        ),
                        // clipper: RectClipper(
                        //   width: MediaQuery.of(context).size.width
                        // ),
                      ),
                    );
                  }
                  return CircularProgressIndicator();
                },
              )
            ),
          ],
        ),
      ),
    );
  }

}

class RectClipper extends CustomClipper<Rect> {

  final double width;

  RectClipper({ @required this.width });

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }

  @override
  Rect getClip(Size size) {
    var w = size.width - 5;
    return Rect.fromLTRB(5, 0, w, 400);
  }
}