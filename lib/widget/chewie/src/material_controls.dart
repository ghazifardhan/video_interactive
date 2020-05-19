import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_interactive/widget/chewie/src/chewie_player.dart';
import 'package:video_interactive/widget/chewie/src/chewie_progress_colors.dart';
import 'package:video_interactive/widget/chewie/src/material_progress_bar.dart';
import 'package:video_interactive/widget/chewie/src/utils.dart';
import 'package:video_player/video_player.dart';

class MaterialControls extends StatefulWidget {
  const MaterialControls({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MaterialControlsState();
  }
}

class _MaterialControlsState extends State<MaterialControls> {
  VideoPlayerValue _latestValue;
  double _latestVolume;
  bool _hideStuff = true;
  Timer _hideTimer;
  Timer _initTimer;
  Timer _showAfterExpandCollapseTimer;
  bool _dragging = false;
  bool _displayTapped = false;

  final barHeight = 48.0;
  final marginSize = 5.0;

  VideoPlayerController controller;
  ChewieController chewieController;

  @override
  Widget build(BuildContext context) {
    if (_latestValue.hasError) {
      return chewieController.errorBuilder != null
          ? chewieController.errorBuilder(
              context,
              chewieController.videoPlayerController.value.errorDescription,
            )
          : Center(
              child: Icon(
                Icons.error,
                color: Colors.white,
                size: 42,
              ),
            );
    }

    // return MouseRegion(
    //   onHover: (_) {
    //     _cancelAndRestartTimer();
    //   },
    //   child: GestureDetector(
    //     onTap: () => _cancelAndRestartTimer(),
    //     child: AbsorbPointer(
    //       absorbing: _hideStuff,
    //       child: Column(
    //         children: <Widget>[
    //           _buildNewHitArea(context)
    //         ],
    //       ),
    //     ),
    //   ),
    // );

    return MouseRegion(
      onHover: (_) {
        _cancelAndRestartTimer();
      },
      child: GestureDetector(
        onTap: () => _cancelAndRestartTimer(),
        child: AbsorbPointer(
          absorbing: _hideStuff,
          // child: _buildBottomBar(context),
          child: Stack(
            children: <Widget>[
              Positioned(
                bottom: 50.0,
                right: 0.0,
                child: _buildSkipTrailer(),
              ),
              Column(
                children: <Widget>[
                  // _latestValue != null && !_latestValue.isPlaying && _latestValue.duration == null || _latestValue.isBuffering
                  //     ? const Expanded(
                  //         child: const Center(
                  //           child: const CircularProgressIndicator(),
                  //         ),
                  //       )
                  //     : _buildHitArea(),
                  Expanded(
                    child: _buildBottomBar(context),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  AnimatedOpacity fadedBlack() {
    return AnimatedOpacity(
      opacity: _hideStuff ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _hideStuff = !_hideStuff;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(0, 0, 0, 0.6),
          ),
        ),
      ),
    );
  }

  Expanded _buildNewHitArea(BuildContext context) {
    return Expanded(
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(0, 0, 0, 0.6),
          ),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _hideStuff = !_hideStuff;
              });
              print("klik lkik");
            },
            child: Stack(
              children: <Widget>[
                Positioned(
                  bottom: 5.0,
                  right: 5.0,
                  child: _buildExpandButton(),
                ),
                _latestValue.isPlaying ? pauseButton() : playButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container pauseButton() {
    return Container(
      child: Center(
        child: AnimatedOpacity(
          opacity: _latestValue != null && _latestValue.isPlaying && !_dragging ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: GestureDetector(
            onTap: () {
              _playPause();
            },
            child: SvgPicture.asset("lib/assets/icons/pause.svg")
          ),
        ),
        )
    );
  }

  Container playButton() {
    return Container(
      child: Center(
        child: AnimatedOpacity(
          opacity: _latestValue != null && !_latestValue.isPlaying && !_dragging ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: Container(
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.6),
            ),
            child: GestureDetector(
              onTap: () {
                if (_latestValue != null && _latestValue.isPlaying) {
                  if (_displayTapped) {
                    setState(() {
                      _hideStuff = true;
                    });
                  } else
                    _cancelAndRestartTimer();
                } else {
                  _playPause();

                  setState(() {
                    _hideStuff = true;
                  });
                }
              },
              child: SvgPicture.asset("lib/assets/icons/play.svg")
            ),
          )
        ),
        )
      )
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final _oldController = chewieController;
    chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (_oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  AnimatedOpacity _buildBottomBar(
    BuildContext context,
  ) {
    final iconColor = Theme.of(context).textTheme.button.color;

    return AnimatedOpacity(
      opacity: _hideStuff ? 0.0 : 1.0,
      duration: Duration(milliseconds: 300),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
              child: Text(
                "Preparing Drinks for Beginner for every Situation part 1",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500
                ),
                textAlign: TextAlign.left,
              ),
            ),
            _latestValue != null && !_latestValue.isPlaying && _latestValue.duration == null || _latestValue.isBuffering
            ? const Expanded(
                child: const Center(
                  child: const CircularProgressIndicator(),
                ),
              )
            : _buildPlayPause(controller),
            Container(
              height: barHeight,
              child: Row(
              children: <Widget>[
                  // _buildPlayPause(controller),
                  chewieController.isLive ? Expanded(child: const Text('LIVE')) : _buildPositionStart(iconColor),
                  chewieController.isLive ? const SizedBox() : _buildProgressBar(),
                  chewieController.isLive ? Expanded(child: const Text('LIVE')) : _buildPositionEnd(iconColor),
                  // chewieController.allowMuting ? _buildMuteButton(controller) : Container(),
                  chewieController.allowFullScreen ? _buildExpandButton() : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildExpandButton() {
    return GestureDetector(
      onTap: _onExpandCollapse,
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: Duration(milliseconds: 300),
        child: Container(
          height: barHeight,
          margin: EdgeInsets.only(right: 10.0),
          padding: EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          child: Center(
            child: Icon(
              chewieController.isFullScreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildPauseArea() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_latestValue != null && !_latestValue.isPlaying) {
            if (_displayTapped) {
              setState(() {
                _hideStuff = true;
              });
            } else
              _cancelAndRestartTimer();
          } else {
            _playPause();

            setState(() {
              _hideStuff = true;
            });
          }
        },
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: AnimatedOpacity(
              opacity:
                  _latestValue != null && !_latestValue.isPlaying && !_dragging
                      ? 1.0
                      : 0.0,
              duration: Duration(milliseconds: 300),
              child: GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).dialogBackgroundColor,
                    borderRadius: BorderRadius.circular(48.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(0.0),
                    // child: Icon(Icons.play_arrow, size: 32.0),
                    child: SvgPicture.asset("lib/assets/icons/pause.svg"),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }



  Expanded _buildHitArea() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          
        },
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: AnimatedOpacity(
              opacity:
                  _latestValue != null && !_latestValue.isPlaying && !_dragging
                      ? 1.0
                      : 0.0,
              duration: Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: () {
                  if (_latestValue != null && _latestValue.isPlaying) {
                    if (_displayTapped) {
                      setState(() {
                        _hideStuff = true;
                      });
                    } else
                      _cancelAndRestartTimer();
                  } else {
                    _playPause();

                    setState(() {
                      _hideStuff = true;
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).dialogBackgroundColor,
                    borderRadius: BorderRadius.circular(48.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(0.0),
                    // child: Icon(Icons.play_arrow, size: 32.0),
                    child: SvgPicture.asset("lib/assets/icons/play.svg"),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildMuteButton(
    VideoPlayerController controller,
  ) {
    return GestureDetector(
      onTap: () {
        _cancelAndRestartTimer();

        if (_latestValue.volume == 0) {
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: Duration(milliseconds: 300),
        child: ClipRect(
          child: Container(
            child: Container(
              height: barHeight,
              padding: EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: Icon(
                (_latestValue != null && _latestValue.volume > 0)
                    ? Icons.volume_up
                    : Icons.volume_off,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildPlayPause(VideoPlayerController controller) {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: _playPause,
          child: controller.value.isPlaying ? SvgPicture.asset("lib/assets/icons/pause.svg") : SvgPicture.asset("lib/assets/icons/play.svg"),
        ),
      ),
    );
  }

  Widget _buildPositionStart(Color iconColor) {
    final position = _latestValue != null && _latestValue.position != null
        ? _latestValue.position
        : Duration.zero;
    final duration = _latestValue != null && _latestValue.duration != null
        ? _latestValue.duration
        : Duration.zero;

    return Padding(
      padding: EdgeInsets.only(left: 10.0),
      child: Text(
        '${formatDuration(position)}',
        style: TextStyle(
          fontSize: 14.0,
          color: Colors.white
        ),
      ),
    );
  }

  Widget _buildSkipTrailer() {
    final position = _latestValue != null && _latestValue.position != null
        ? _latestValue.position
        : Duration.zero;
    final duration = _latestValue != null && _latestValue.duration != null
        ? _latestValue.duration
        : Duration.zero;

    final minusDuration = Duration(seconds: 5) - position;
    var text = "";
    if (minusDuration < Duration(seconds: 1)) {
      text = "Skip Trailer";
    } else {
      text = minusDuration.inSeconds.toString();
    }

    return Container(
      height: 40,
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.9),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Row(
            children: <Widget>[
              Text(
                "$text",
                style: TextStyle(
                  color: Color(0xff2F8CB2),
                ),
              ),
              Icon(
                Icons.play_arrow,
                color: Color(0xff2F8CB2),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPositionEnd(Color iconColor) {
    final position = _latestValue != null && _latestValue.position != null
        ? _latestValue.position
        : Duration.zero;
    final duration = _latestValue != null && _latestValue.duration != null
        ? _latestValue.duration
        : Duration.zero;

    final minusDuration = duration - position;

    return Padding(
      padding: EdgeInsets.only(right: 0.0),
      child: Text(
        '- ${formatDuration(minusDuration)}',
        style: TextStyle(
          fontSize: 14.0,
          color: Colors.white
        ),
      ),
    );
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      _hideStuff = false;
      _displayTapped = true;
    });
  }

  Future<Null> _initialize() async {
    controller.addListener(_updateState);

    _updateState();

    if ((controller.value != null && controller.value.isPlaying) ||
        chewieController.autoPlay) {
      _startHideTimer();
    }

    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(Duration(milliseconds: 200), () {
        setState(() {
          _hideStuff = false;
        });
      });
    }
  }

  void _onExpandCollapse() {
    setState(() {
      _hideStuff = true;

      chewieController.toggleFullScreen();
      _showAfterExpandCollapseTimer = Timer(Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  void _playPause() {
    bool isFinished;
    if( _latestValue.duration != null)
    {
      isFinished = _latestValue.position >= _latestValue.duration;
    }
    else
    {
      isFinished = false;
    }

    setState(() {
      if (controller.value.isPlaying) {
        _hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller.value.initialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          if (isFinished) {
            controller.seekTo(Duration(seconds: 0));
          }
          controller.play();
        }
      }
    });
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 1), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void _updateState() {
    setState(() {
      _latestValue = controller.value;
    });
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: MaterialVideoProgressBar(
          controller,
          onDragStart: () {
            setState(() {
              _dragging = true;
            });
            _hideTimer?.cancel();
          },
          onDragEnd: () {
            setState(() {
              _dragging = false;
            });

            _startHideTimer();
          },
          colors: chewieController.materialProgressColors ??
              ChewieProgressColors(
                  playedColor: Color(0xffD02D91),
                  handleColor: Color(0xffD02D91),
                  bufferedColor: Color(0xffE5E5E5),
                  backgroundColor: Color(0xffE5E5E5)
              ),
        ),
      ),
    );
  }
}
