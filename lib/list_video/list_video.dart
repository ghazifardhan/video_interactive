import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_interactive/bloc/from.dart';
import 'package:video_interactive/bloc/list_video_bloc.dart';
import 'package:video_interactive/bloc/scroll_bloc.dart';
import 'package:video_interactive/widget/video/kriya_video.dart';
import 'package:video_player/video_player.dart';

class ListVideo extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _ListVideoPage();
  }

}

class _ListVideoPage extends State<ListVideo> {

  ScrollBloc _scrollBloc;

  @override
  void initState() {
    super.initState();

    _scrollBloc = ScrollBloc();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ListVideoBloc>(
          create: (context) => ListVideoBloc()..add(InitializeListVideoBlocEvent())
        ),
        BlocProvider<ScrollBloc>(
          create: (context) => _scrollBloc
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text("List Video"),
        ),
        body: Container(
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollEndNotification) {
                Future.delayed(Duration(milliseconds: 500), () {
                  _scrollBloc..add(ScrollAttachedEvent(scrollNotification: scrollNotification));
                });
              }
              return false;
            },
            child: ChildListVideo(),
          ),
        ),
      )
    );
  }

}

class ChildListVideo extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _ChildListVideoPage();
  }

}

class _ChildListVideoPage extends State<ChildListVideo> {

  ListVideoBloc _listVideoBloc;
  ScrollBloc _scrollBloc;

  @override
  void initState() {
    super.initState();

    _listVideoBloc = BlocProvider.of<ListVideoBloc>(context);
    _scrollBloc = BlocProvider.of<ScrollBloc>(context);
  }

  @override
  void dispose() {
    _listVideoBloc.close();
    _scrollBloc.close();
    super.dispose();
  }

  scrollController(ScrollReadyState state) {
    print("mantap gan ${_listVideoBloc.datas.length}");
    _listVideoBloc.datas.asMap().forEach((k, v){
          double offset = MediaQuery.of(context).size.height / 3;
          WidgetsBinding.instance.addPostFrameCallback((_){
            RenderBox box = v.key.currentContext.findRenderObject();
            Offset position = box.localToGlobal(Offset.zero); //
            double y = position.dy;

            if (y >= -25 && y < offset) {
              print("${v.url} ${v.key} load");
              _listVideoBloc..add(ChangeVideoPlayerEvent(playingIndex: k));
      //        v.key.currentState.playVideo();
            }
            else {
              // print("${v.url} ${v.key} unload");
      //        v.key.currentState.pauseVideo();
            }
          });
    });

    final maxScroll = state.scrollNotification.metrics.maxScrollExtent;
    final currentScroll = state.scrollNotification.metrics.pixels;
    if (maxScroll - currentScroll <= 0) {
      print("add more gan");
      _listVideoBloc..add(AddMoreVideoEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScrollBloc, ScrollState>(
      builder: (BuildContext context, ScrollState scrollState) {
        if (scrollState is ScrollReadyState) {
          scrollController(scrollState);
        }
        return BlocBuilder<ListVideoBloc, ListVideoBlocState>(
          builder: (BuildContext context, ListVideoBlocState state) {
            if (state is InitializedListVideoState) {
              return videos(state);
            }
            return Container();
          },
        );
      },
    );
  }

  Widget videos(InitializedListVideoState state) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: state.datas.length,
      separatorBuilder: (context, index) {
        return Container(height: 10.0,);
      },
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: Container(
            key: state.datas[index].key,
            height: 200.0,
            color: Colors.grey,
            child: state.playingIndex == index
                ?
                KriyaPlayer(
                  key: Key(index.toString()),
                  videoBloc: state.videoPlayerBloc, 
                  fullscreen: false, 
                  from: From.MY_COURSES
                )
                : Container(child: Text("Video Unload ${state.datas[index].key}"),)
          ),
        );
      },
    );
  }

}