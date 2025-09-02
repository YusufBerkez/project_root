import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  List<File> videoFiles = [];
  
  // Video dosyalarının Raspberry Pi'deki konumu. Kendi yolunuza göre düzenleyin.
  final String videoDirectoryPath = '/home/pi/Desktop/backend/videos/'; 
  //final String videoDirectoryPath = '/storage/emulated/0/Movies/Instagram/'; 

  @override
  void initState() {
    super.initState();
    // Widget oluşturulduktan sonra izin kontrolünü başlatır.
    // Bu, "dependOnInheritedWidgetOfExactType" hatasını önler.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestPermissions();
    });
  }
  
  // Depolama iznini kontrol eder ve kullanıcı dostu bir şekilde ister.
  Future<void> _checkAndRequestPermissions() async {
  var status = await Permission.storage.status;

  if (status.isDenied) {
    status = await Permission.storage.request();
  }

  if (status.isGranted) {ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Video oynatmak için depolama izni gerekli.'),
      ),
    );
    
  } else {
    // İzin reddedildiyse kullanıcıya bildirim göster
    _listVideoFiles();
  }
}

  // Belirtilen dizindeki video dosyalarını listeler.
  void _listVideoFiles() {
    final directory = Directory(videoDirectoryPath);
    if (directory.existsSync()) {
      videoFiles = directory.listSync().whereType<File>().toList();
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video dizini bulunamadı veya erişilemiyor.'),
        ),
      );
    }
  }

  // Seçilen videoyu oynatır.
  void _playVideo(File file) {
    if (_controller != null) {
      _controller!.dispose();
    }
    _controller = VideoPlayerController.file(file);
    _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
      setState(() {});
      _controller!.play();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Video oynatılamadı: $error'),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raspberry Pi Videoları'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: _initializeVideoPlayerFuture == null
                ? const Center(
                    child: Text('Oynatmak için bir video seçin.'),
                  )
                : FutureBuilder(
                    future: _initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done && _controller != null) {
                        return AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        );
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Video yüklenirken bir hata oluştu.'));
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: videoFiles.length,
              itemBuilder: (context, index) {
                final file = videoFiles[index];
                return ListTile(
                  title: Text(
                    file.path.split('/').last,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  onTap: () {
                    _playVideo(file);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _controller == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                });
              },
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
    );
  }
}