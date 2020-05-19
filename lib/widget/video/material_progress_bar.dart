import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_interactive/bloc/video_player/video_player_bloc.dart';
import 'package:video_interactive/bloc/video_player/video_player_state.dart';
import 'package:video_interactive/widget/theme.dart';
import 'package:video_player/video_player.dart';

class MaterialVideoProgressBar extends StatefulWidget {

  @override
  _VideoProgressBarState createState() {
    return _VideoProgressBarState();
  }
}

class _VideoProgressBarState extends State<MaterialVideoProgressBar> {
  VideoPlayerBloc _videoPlayerBloc;

  @override
  void initState() {
    super.initState();
    _videoPlayerBloc = BlocProvider.of<VideoPlayerBloc>(context);
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      child: Center(
        child: Container(
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width,
          color: Colors.transparent,
          child: BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
            builder: (context, state) {
              if (state is VideoInitializedState) {
                return CustomPaint(
                  painter: _ProgressBarPainter(state),
                );
              }
            },
          ),
        ),
      )
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter(this.state);

  VideoInitializedState state;

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final height = 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, size.height / 2),
          Offset(size.width, size.height / 2 + height),
        ),
        Radius.circular(4.0),
      ),
      Paint()..color = KriyaColor().graysE5E5E5,
    );
    if (!state.videoPlayerController.value.initialized) {
      return;
    }
    final double playedPartPercent =
        state.videoPlayerController.value.position.inMilliseconds / state.videoPlayerController.value.duration.inMilliseconds;
    final double playedPart =
        playedPartPercent > 1 ? size.width : playedPartPercent * size.width;
    for (DurationRange range in state.videoPlayerController.value.buffered) {
      final double start = range.startFraction(state.videoPlayerController.value.duration) * size.width;
      final double end = range.endFraction(state.videoPlayerController.value.duration) * size.width;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(start, size.height / 2),
            Offset(end, size.height / 2 + height),
          ),
          Radius.circular(4.0),
        ),
        Paint()..color = KriyaColor().graysE5E5E5,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, size.height / 2),
          Offset(playedPart, size.height / 2 + height),
        ),
        Radius.circular(4.0),
      ),
      Paint()..color = KriyaColor().kriyaLabD02D91,
    );
    canvas.drawCircle(
      Offset(playedPart, size.height / 2 + height / 2),
      height * 2,
      Paint()..color = KriyaColor().kriyaLabD02D91,
    );
  }
}
