import 'dart:io';
import 'package:camera_interface/fulscreen_video_page.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  List<File> videoFiles = [];

  String get videoDirectoryPath {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return 'C:\\Users\\Administrator\\Videos\\Ekran Kayıtları';
    } else if (defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS) {
      return '${Platform.environment['HOME']}/Videos';
    }
    return '/storage/emulated/0/Movies/';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionsAndListFiles();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    // Uygulama kapatılırken dikey moda geri dön
    _exitFullScreen();
    super.dispose();
  }

  // Yeni özellikler
  void _setFullScreen() {
  if (_controller != null) {
    // Video kontrolcüsünü yeni sayfaya gönder
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPage(controller: _controller!),
      ),
    );
  }
}

  void _exitFullScreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _seekForward() {
    if (_controller != null) {
      final position = _controller!.value.position;
      final newPosition = position + const Duration(seconds: 10);
      _controller!.seekTo(newPosition);
    }
  }

  void _seekBackward() {
    if (_controller != null) {
      final position = _controller!.value.position;
      final newPosition = position - const Duration(seconds: 10);
      _controller!.seekTo(newPosition);
    }
  }

  void _toggleMute() {
    if (_controller != null) {
      final isMuted = _controller!.value.volume == 0;
      _controller!.setVolume(isMuted ? 1.0 : 0.0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isMuted ? 'Ses açıldı' : 'Ses kapatıldı'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _checkPermissionsAndListFiles() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final int sdkVersion = androidInfo.version.sdkInt;

      PermissionStatus status;
      if (sdkVersion >= 33) {
        status = await Permission.videos.request();
      } else {
        status = await Permission.storage.request();
      }

      if (status.isGranted) {
        _listVideoFiles();
      } else if (status.isPermanentlyDenied) {
        _showSettingsDialog();
      } else {
        _showPermissionDialog();
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      if (status.isGranted) {
        _listVideoFiles();
      } else if (status.isPermanentlyDenied) {
        _showSettingsDialog();
      } else {
        _showPermissionDialog();
      }
    } else {
      _listVideoFiles();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Depolama İzni Gerekiyor'),
          content: const Text('Video dosyalarını listelemek için depolama iznine ihtiyacımız var.'),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Video oynatmak için depolama izni gereklidir.'),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('İzin Ver'),
              onPressed: () {
                Navigator.of(context).pop();
                _checkPermissionsAndListFiles();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('İzin Gerekiyor'),
          content: const Text('Depolama izni kalıcı olarak reddedildi. Lütfen ayarlardan manuel olarak izin verin.'),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ayarlara Git'),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _listVideoFiles() {
    final directory = Directory(videoDirectoryPath);
    if (!directory.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: Video dizini bulunamadı veya erişilemiyor: $videoDirectoryPath'),
        ),
      );
      return;
    }
    final files = directory.listSync().whereType<File>().where((file) {
      return file.path.toLowerCase().endsWith('.mp4');
    }).toList();
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belirtilen dizinde video dosyası bulunamadı.'),
        ),
      );
    }
    setState(() {
      videoFiles = files;
    });
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan,
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
                        return Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            AspectRatio(
                              aspectRatio: _controller!.value.aspectRatio,
                              child: VideoPlayer(_controller!),
                            ),
                            // Video Kontrol Çubuğu
                            VideoProgressIndicator(
                              _controller!,
                              allowScrubbing: true,
                              colors: const VideoProgressColors(
                                playedColor: Colors.red,
                                bufferedColor: Colors.grey,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Video yüklenirken bir hata oluştu.'));
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
          ),
          // Kontrol Butonları
          if (_controller != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10, color: Colors.black),
                    onPressed: _seekBackward,
                  ),
                  IconButton(
                    icon: Icon(
                      _controller!.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                      color: Colors.black,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_10, color: Colors.black),
                    onPressed: _seekForward,
                  ),
                  IconButton(
                    icon: Icon(
                      _controller!.value.volume == 0 ? Icons.volume_off : Icons.volume_up,
                      color: Colors.black,
                    ),
                    onPressed: _toggleMute,
                  ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen, color: Colors.black),
                    onPressed: _setFullScreen,
                  ),
                ],
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
      floatingActionButton: null, // Eski FAB kaldırıldı
    );
  }
}