import 'dart:math' as m;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:zimpligital_phutaneat_kr/main.dart';

const colorMain = Color(0xFF142E3E);
const colorBody = Color(0xFF214762);
const colorSelect = Color(0xFF2E6288);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: PlayListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PlayListPage extends StatefulWidget {
  const PlayListPage({super.key});

  @override
  State<PlayListPage> createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> with WidgetsBindingObserver {
  final AudioPlayer _player = AudioPlayer();

  Music? _current;

  List<Music> _listMusics = [];
  List<String> _tabs = ['UP NEXT', 'LYRICS'];
  String _tab = 'UP NEXT';

  @override
  void initState() {
    super.initState();
    _init();
    _player.onPlayerComplete.listen((event) => _stop());

    WidgetsBinding.instance.addObserver(this);
  }

  void _init() {
    final m.Random random = m.Random();
    final List<Music> lists = [];
    for (int i = 0; i < 20; i++) {
      int randomIndex = random.nextInt(playlists.length);
      Music newMusic = playlists[randomIndex];
      newMusic = newMusic.copyWith(id: i + 1, rn: i);
      lists.add(newMusic);
    }
    setState(() => _listMusics = lists);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      if (_current != null) await _pause();
    }
  }

  Future<void> _play() async {
    await _player.play(AssetSource(_current!.source));
    setState(() => _current!.state = PlayerState.playing);
  }

  Future<void> _pause() async {
    await _player.pause();
    setState(() => _current!.state = PlayerState.paused);
  }

  Future<void> _stop() async {
    await _player.stop();
    setState(() {
      _current!.state = PlayerState.stopped;
    });
  }

  void _onSelectMusic(Music m) async {
    await _player.stop();
    setState(() {
      _current = m;
      _current!.state = PlayerState.stopped;
      _play();
    });
  }

  Widget _widgetHead() {
    if (_current != null) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Image.asset(_current!.img, width: 60, height: 60, fit: BoxFit.cover),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _current!.name,
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _current!.album,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: Row(
                children: [
                  _current!.rn != 0
                      ? GestureDetector(
                          onTap: () => {_onSelectMusic(_listMusics[_current!.rn - 1])},
                          child: Icon(Icons.skip_previous, color: Colors.white, size: 25),
                        )
                      : SizedBox(width: 25),
                  SizedBox(width: 12),
                  GestureDetector(
                    onTap: (_current!.state == PlayerState.playing) ? _pause : _play,
                    child: Icon((_current!.state == PlayerState.playing) ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 25),
                  ),
                  SizedBox(width: 12),
                  _current!.rn != _listMusics.length - 1
                      ? GestureDetector(
                          onTap: () => {_onSelectMusic(_listMusics[_current!.rn + 1])},
                          child: Icon(Icons.skip_next, color: Colors.white, size: 25),
                        )
                      : SizedBox(width: 25),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _widgetTab() {
    return Container(
      color: colorBody,
      child: Column(
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 8),
              decoration: BoxDecoration(color: colorSelect, borderRadius: BorderRadius.circular(16)),
              height: 6,
              width: 40,
            ),
          ),
          Row(
            children: _tabs.map((d) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tab = d),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      border: _tab == d ? Border(bottom: BorderSide(color: Colors.white, width: 3.0)) : null,
                    ),
                    child: Text(
                      d,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _widgetList() {
    if (_tab == 'UP NEXT') {
      return Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: _listMusics.map((music) {
              bool isSelect = _current != null && _current!.id == music.id;
              return Container(
                color: isSelect ? colorSelect : colorBody,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Image.asset(music.img, width: 80, height: 80, fit: BoxFit.cover),
                        ),
                        if (isSelect)
                          Center(
                            child: Container(
                              width: 50,
                              height: 50,
                              color: Colors.black.withValues(alpha: isSelect ? 0.5 : 0),
                              child: Center(child: Icon(Icons.bar_chart, color: Colors.white, size: 24)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  title: Text(
                    music.name,
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Row(
                    children: [
                      Text(music.album, style: TextStyle(color: Colors.grey, fontSize: 13)),
                      SizedBox(width: 8),
                      Text(music.duration, style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  trailing: Icon(Icons.drag_handle, color: Colors.white54, size: 20),
                  onTap: () => _onSelectMusic(music),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0, backgroundColor: colorMain),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: colorMain,
        child: Column(children: [_widgetHead(), _widgetTab(), _widgetList()]),
      ),
    );
  }
}
