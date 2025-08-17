import 'package:flutter/material.dart';
import 'package:mjpeg_view/mjpeg_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CameraHome extends StatefulWidget {
  @override
  _CameraHomeState createState() => _CameraHomeState();
}

class _CameraHomeState extends State<CameraHome> {
  String backendIP = "192.168.1.38:5000"; // Python backend IP
  String ipCameraURL = "http://192.168.1.35:8080/video"; // Telefon IP kamera URL
  bool recording = false;
  List<String> videos = [];

  Future<void> capturePhoto() async {
    final res = await http.get(Uri.parse("http://$backendIP/capture_photo"));
    print(res.body);
  }

  Future<void> startVideo() async {
    final res = await http.get(Uri.parse("http://$backendIP/start_video"));
    print(res.body);
    setState(() {
      recording = true;
    });
  }

  Future<void> stopVideo() async {
    final res = await http.get(Uri.parse("http://$backendIP/stop_video"));
    print(res.body);
    setState(() {
      recording = false;
    });
  }

  Future<void> getVideos() async {
    final res = await http.get(Uri.parse("http://$backendIP/get_videos"));
    setState(() {
      videos = List<String>.from(json.decode(res.body));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Raspberry Pi / IP Kamera Test")),
      body: Column(
        children: [
          // Canlı görüntü
          Expanded(
            child: MjpegView(
              uri: ipCameraURL, // 1.0.1 sürümünde 'uri' kullanılıyor
              
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: capturePhoto, child: Text("Fotoğraf")),
              ElevatedButton(
                  onPressed: recording ? stopVideo : startVideo,
                  child: Text(recording ? "Durdur" : "Video")),
              ElevatedButton(
                  onPressed: getVideos, child: Text("Videoları Listele")),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(videos[index]),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
