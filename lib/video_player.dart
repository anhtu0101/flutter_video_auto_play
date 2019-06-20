import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class HomeVideoPlayTest extends StatefulWidget {
  static final String route = '/home_video_play';

  @override
  _HomeVideoPlayTestState createState() => _HomeVideoPlayTestState();
}

class _HomeVideoPlayTestState extends State<HomeVideoPlayTest> with SingleTickerProviderStateMixin {
  VideoPlayerController _controllerMain;

  AnimationController animationController;
  Animation animationLeftToRight,animationRightToLeft, animationBottomToTop;

  bool _disposedMain = false;
  bool _isPlaying = false;
  bool _isPlayingComplete = false;
  int _playingIndex = -1;

  String introUrl;
  List adsOnline = ['https://download.blender.org/peach/trailer/trailer_iphone.m4v','http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4'];
  List adsOnline2 = ['https://www.html5rocks.com/en/tutorials/video/basics/devstories.mp4'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    startPlayAdsMain(0,adsOnline);
    animationController = AnimationController(
        duration: Duration(milliseconds: 4000), vsync: this);

    animationRightToLeft = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn));
    animationBottomToTop = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn));
    animationLeftToRight = Tween(begin: -0.15, end: 0.0).animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    ));
  }

  @override
  void dispose() {
    _disposedMain = true;
    _controllerMain?.pause()?.then((_) {
      _controllerMain?.dispose();
    });
    super.dispose();
  }




  Future<bool> _clearPrevious() async {
    await _controllerMain?.pause();
    _controllerMain?.removeListener(_controllerListenerMain);
    return true;
  }

  Future<void> _startPlay(int index) async {
    print("play ---------> $index");

    Future.delayed(const Duration(milliseconds: 200), () {
      _clearPrevious().then((_){
        startPlayAdsMain(index,adsOnline);
      });
    });
  }

  Future<void> _startPlayIntro() async {
    print("play ---------> introoo");

    Future.delayed(const Duration(milliseconds: 200), () {
      _clearPrevious().then((_){
        playIntro();
      });
    });
  }

  Future<void> playIntro() async {
    print("Introl --->");
    _controllerMain = VideoPlayerController.network(adsOnline2[0])
      ..initialize().then((_) {
        setState(() {
          if (_controllerMain.value.initialized) {
            _controllerMain.play();
          }
        });
      });
    _controllerMain.addListener(_controllerListenerMain);
  }


  Future<void> startPlayAdsMain(int index, List _ads) async {
    _isPlaying = true;
    _controllerMain = VideoPlayerController.network(adsOnline[index])
      ..initialize().then((_) {
        setState(() {
          if (_controllerMain.value.initialized) {
            _controllerMain.play();
          }
        });
        print("_controllerMain.value.initialized ${_controllerMain.value.initialized}");
      });
    _controllerMain.addListener(_controllerListenerMain);
    setState(() {
      _playingIndex = index;
    });
  }

  Future<void> _controllerListenerMain() async {
    if (_controllerMain == null || _disposedMain) {
      return;
    }
    if (!_controllerMain.value.initialized) {
      return;
    }
    final position = await _controllerMain.position;
    final duration = _controllerMain.value.duration;
    if (position != null && duration != null) {
      final isPlaying = position.inMilliseconds < duration.inMilliseconds;
      final isEndPlaying = position.inMilliseconds > 0 && position.inSeconds == duration.inSeconds;
      if (_isPlaying != isPlaying || _isPlayingComplete != isEndPlaying) {
        _isPlaying = isPlaying;
        _isPlayingComplete = isEndPlaying;
        print("isEndPlaying  $isEndPlaying");
        if (isEndPlaying) {
          final isComplete = _playingIndex == adsOnline.length - 1;
          if (isComplete) {
            print("played all!!");
            _startPlayIntro();
//            _startPlay(0);
          } else {
            _startPlay(_playingIndex + 1);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    Size screenSize = MediaQuery.of(context).size;
    animationController.forward();
    return AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          return Scaffold(
            body: layout0(context),
          );
        });
  }

  Widget buildPlayerLayout(BuildContext context, int layout) {
    return Container(
      child: layout0(context),
    );
  }

  Widget _mainVideoLayout0(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        Container(
          child: _controllerMain.value.initialized ?
          AspectRatio(
            aspectRatio: _controllerMain.value.aspectRatio,
            child: VideoPlayer(_controllerMain),
          ) : Container(
            child: Text("Empty",style: TextStyle(color: Colors.white),),
          ),
        ),
      ],
    );
  }


  Widget layout0(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    return Container(
      color: Colors.black,
      child: _mainVideoLayout0(context),
    );
  }
}
