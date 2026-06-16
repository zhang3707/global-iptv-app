import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // 💥 确保用的是这个，彻底丢掉 fijk
import '../models/channel.dart';

class PlayerPage extends StatefulWidget {
  final Channel channel;
  const PlayerPage({Key? key, required this.channel}) : super(key: key);

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  String _errorMsg = "";

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() async {
    try {
      // 📡 官方内核全网自动并网：在 Chrome / Windows 上完美承载数据
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.channel.url),
        httpHeaders: {
          'User-Agent': widget.channel.userAgent, // 透传我们在云端洗出来的 UA 防盗链
        },
      );

      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _controller.play(); // 🎬 自动点火开播
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = "视频源解码失败，或由于跨域(CORS)限制被视频服务器拦截\n详情: $e";
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // 🔌 强行释放显卡和内存资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.channel.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _errorMsg.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(_errorMsg, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
              )
            : _isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(color: Colors.white), // 漂亮的白色缓冲菊花圈
      ),
    );
  }
}