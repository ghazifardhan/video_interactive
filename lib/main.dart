import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_interactive/interactive/chewie_test.dart';
import 'package:video_interactive/interactive/download_file.dart';
import 'package:video_interactive/interactive/new_interactive.dart';
import 'package:video_interactive/interactive/new_interactive_v2.dart';
import 'package:video_interactive/interactive/new_video.dart';
import 'package:video_interactive/interactive/video.dart';
import 'package:video_interactive/list_video/list_video.dart';
import 'package:video_interactive/list_video/list_video_new.dart';
import 'package:video_interactive/simple_bloc_delegate.dart';

import 'interactive/video_quality.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();


    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CupertinoButton(
              child: Text("Video Interactive from Network"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Video(from: "network")));
              },
            ),
            CupertinoButton(
              child: Text("Video Interactive from Asset"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => NewInteractive()));
              },
            ),
            CupertinoButton(
              child: Text("Video Interactive V2"),
              onPressed: () {
                Navigator.push(context, CupertinoPageRoute(builder: (context) => NewInteractiveV2()));
              },
            ),
            CupertinoButton(
              child: Text("List Video"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ListVideo()));
              },
            ),
            CupertinoButton(
              child: Text("Chewie Video"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChewieTest()));
              },
            ),
            CupertinoButton(
              child: Text("Download Page"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DownloadFile()));
              },
            ),
            CupertinoButton(
              child: Text("Video Quality"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => VideoQuality()));
              },
            ),
          ],
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
