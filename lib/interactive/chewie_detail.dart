import 'package:flutter/material.dart';
import 'package:video_interactive/widget/chewie/src/chewie_player.dart';
import 'package:video_player/video_player.dart';

class ChewieDetail extends StatefulWidget {
  
  final VideoPlayerController videoPlayerController;

  ChewieDetail({ @required this.videoPlayerController });

  @override
  State<StatefulWidget> createState() {
    return _ChewieDetailPage();
  }

}

class _ChewieDetailPage extends State<ChewieDetail> {

  ChewieController _chewieController;
  Future<void> _future;

  @override
  void initState() {
    super.initState();

    _future = initVideoPlayer();

    widget.videoPlayerController.addListener(() {
      // print("${widget.videoPlayerController}");
      // if (widget.videoPlayerController.value.isBuffering) {
      //   print("buffering");
      // } else {
      //   print("not buffering");
      // }
      
    });
  }

  
  void dispose() {
    _chewieController.dispose();
    super.dispose();
  }

  Future<void> initVideoPlayer() async {
    await widget.videoPlayerController.initialize();
    setState(() {
      print(widget.videoPlayerController.value.aspectRatio);
      _chewieController = ChewieController(
        videoPlayerController: widget.videoPlayerController,
        aspectRatio: widget.videoPlayerController.value.aspectRatio,
        autoPlay: true,
        looping: false,
        fullScreenByDefault: true,
        allowFullScreen: true
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return new Center(
          child: widget.videoPlayerController.value.initialized
          ? AspectRatio(
            aspectRatio: widget.videoPlayerController.value.aspectRatio,
            child: Chewie(
              controller: _chewieController,
            ),
          )
          : new CircularProgressIndicator(),
        );
      }
    );
  }

}