import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class Music {
  int id;
  int rn;

  String name;
  String album;
  String img;
  String source;
  String duration;

  PlayerState state = PlayerState.stopped;

  Music({required this.id, required this.name, required this.album, required this.duration, required this.img, required this.source, this.rn = 0});

  Music copyWith({int? id, int? rn}) {
    return Music(id: id ?? this.id, rn: rn ?? this.rn, name: name, album: album, duration: duration, img: img, source: source);
  }
}

List<Music> playlists = [
  Music(id: 1, name: "For the Rest of My Life", album: "Beò, The North", duration: "3:24", img: 'assets/image/p1.jpg', source: 'music/p1.mp3'),
  Music(id: 2, name: "Are You Ready for Me Baby", album: "Funky Giraffe", duration: "2:51", img: 'assets/image/p2.jpg', source: 'music/p2.mp3'),
  Music(id: 3, name: "Ballerina", album: "Yehezkel Raz", duration: "4:26", img: 'assets/image/p3.jpg', source: 'music/p3.mp3'),
  Music(id: 4, name: "Caution", album: "Skrxlla", duration: "2:05", img: 'assets/image/p4.jpg', source: 'music/p4.mp3'),
  Music(id: 5, name: "We'll Come Round", album: "Louis Island", duration: "2:48", img: 'assets/image/p5.jpg', source: 'music/p5.mp3'),
];

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
      home: const PlayListPage(title: 'My PlayList'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PlayListPage extends StatefulWidget {
  const PlayListPage({super.key, required this.title});

  final String title;

  @override
  State<PlayListPage> createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> with WidgetsBindingObserver {
  final AudioPlayer _player = AudioPlayer();

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  Music? _current;

  @override
  void initState() {
    super.initState();

    _player.onDurationChanged.listen((d) => setState(() => _duration = d));
    _player.onPositionChanged.listen((p) => setState(() => _position = p));
    _player.onPlayerComplete.listen((event) => _stop());

    WidgetsBinding.instance.addObserver(this);
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
      _duration = Duration.zero;
      _position = Duration.zero;
      _current!.state = PlayerState.stopped;
    });
  }

  void _onSelectMusic(Music m) async {
    await _player.stop();
    setState(() {
      _duration = Duration.zero;
      _position = Duration.zero;
      _current = m;
      _current!.state = PlayerState.stopped;
      _play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              //color: Colors.green,
              margin: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: playlists.map((music) {
                  return InkWell(
                    onTap: () => _onSelectMusic(music),
                    splashColor: Colors.grey.withValues(alpha: 0.2),
                    highlightColor: Colors.grey.withValues(alpha: 0.1),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.asset(music.img, width: 70, height: 70, fit: BoxFit.cover),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(music.name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                Text(music.album, style: TextStyle(fontSize: 15, color: Colors.grey)),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 35,
                            height: 35,
                            child: Icon(
                              (_current != null && _current!.id == music.id && _current!.state == PlayerState.playing)
                                  ? Icons.pause_circle_outlined
                                  : Icons.play_circle_outlined,
                              size: 28,
                              color: Colors.grey,
                            ),
                          ),
                          //OutlinedButton(onPressed: _stop, child: Text("xxx")),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (_current != null)
            Container(
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
                      activeTrackColor: Colors.yellow.shade600,
                      inactiveTrackColor: Colors.grey,
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _position.inSeconds.toDouble(),
                      max: _duration.inSeconds.toDouble(),
                      onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Image.asset(_current!.img, width: 70, height: 70, fit: BoxFit.cover),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_current!.name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                              Text(_current!.album, style: TextStyle(fontSize: 15, color: Colors.grey)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: (_current!.state == PlayerState.playing) ? _pause : _play,
                          child: SizedBox(
                            width: 35,
                            height: 35,
                            child: Icon((_current!.state == PlayerState.playing) ? Icons.pause : Icons.play_arrow, size: 40, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
