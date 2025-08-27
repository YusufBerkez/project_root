import 'package:flutter/material.dart';
import 'package:mjpeg_view/mjpeg_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CameraHome extends StatefulWidget {
  @override
  _CameraHomeState createState() => _CameraHomeState();
}

class _CameraHomeState extends State<CameraHome> {
  // Raspberry Pi'nin IP adresini hostname -I çıktısından alıp buraya yaz
  String backendIP = "172.20.10.4:5000"; // Örnek, seninkini yaz
  bool recording = false;
  List<String> videos = [];
  List<String> photos = [];

  // --- Fotoğraf Çekme ---
  Future<void> capturePhoto() async {
    final res = await http.get(Uri.parse("http://$backendIP/capture_photo"));
    print(res.body);
  }

  // --- Video Başlatma ---
  Future<void> startVideo() async {
    final res = await http.get(Uri.parse("http://$backendIP/start_video"));
    print(res.body);
    setState(() {
      recording = true;
    });
  }

  // --- Video Durdurma ---
  Future<void> stopVideo() async {
    final res = await http.get(Uri.parse("http://$backendIP/stop_video"));
    print(res.body);
    setState(() {
      recording = false;
    });
  }

  // --- Medya Dosyalarını Çekme ---
  Future<void> getMedia() async {
    final res = await http.get(Uri.parse("http://$backendIP/get_media"));
    final data = json.decode(res.body);
    setState(() {
      videos = List<String>.from(data["videos"]);
      photos = List<String>.from(data["photos"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan,
      appBar: AppBar(title: Container(
        height: 200,
        alignment: Alignment.center,
        child: Image.asset("images/ilab.png",fit: BoxFit.contain,),),
        backgroundColor: Colors.cyan.shade200,
      ),
      body: Column(
        children: [
          // Canlı Görüntü (Raspberry Pi stream)
          Expanded(
            child: MjpegView(
              uri: "http://$backendIP/stream", // Artık backend stream endpoint
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: capturePhoto, child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.camera_alt_outlined,color: Colors.black,),
                  SizedBox(width: 10,),
                  Text("Fotoğraf",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                ],
              ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green
                ),
              ),
              ElevatedButton(
                  onPressed: recording ? stopVideo : startVideo,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam_outlined,size: 20, color: recording ? Colors.green : Colors.red),
                      SizedBox(width: 10,),
                      Text(recording ? "Durdur" : "Video",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: recording ? Colors.red : Colors.green),
                  ),
              ElevatedButton(onPressed: getMedia, child: Text("Medya Listele :",style: TextStyle(color: Colors.grey),
              
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black
              ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                Text("📹 Videolar:", style: TextStyle(fontWeight: FontWeight.bold)),
                ...videos.map((v) => ListTile(title: Text(v))),
                Divider(),
                Text("📷 Fotoğraflar:", style: TextStyle(fontWeight: FontWeight.bold)),
                ...photos.map((p) => ListTile(title: Text(p))),
              ],
            ),
          )
        ],
      ),
    );
  }
}
