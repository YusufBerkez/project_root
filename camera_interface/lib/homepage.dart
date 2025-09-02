import 'package:camera_interface/videoscreen.dart';
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
   String backendIP = "172.30.0.93:5000"; // Örnek, seninkini yaz
  //String backendIP = "192.168.1.36:8080"; // Örnek, seninkini yaz
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
              //uri: "http://$backendIP/video", // Artık backend stream endpoint
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(onPressed: capturePhoto, child:   
                    Text("Fotoğraf 📷",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),overflow: TextOverflow.ellipsis, maxLines: 1,),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                    onPressed: recording ? stopVideo : startVideo,
                    child:   
                        Text(recording ? "Durdur" : "Video 📹",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis, maxLines: 1,),                    
                    style: ElevatedButton.styleFrom(backgroundColor: recording ? Colors.red : Colors.green),
                    ),
              ),
              Expanded(
                child: ElevatedButton(onPressed: getMedia, child: Text("Medya Listele :",style: TextStyle(color: Colors.grey),overflow: TextOverflow.ellipsis, maxLines: 2,),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black
                ),
                ),
              ),
              Expanded(
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>VideoPlayerScreen()));
                }, child: Text("Video Oynatıcıya Git",overflow: TextOverflow.ellipsis, maxLines: 2,),style: ElevatedButton.styleFrom(backgroundColor: Colors.red,foregroundColor: Colors.white),),
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
