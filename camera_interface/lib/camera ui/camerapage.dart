import 'package:camera_interface/camera%20ui/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:mjpeg_view/mjpeg_view.dart';
import 'package:http/http.dart' as http;

class Camerapage extends StatefulWidget {
  const Camerapage({super.key});

  @override
  State<Camerapage> createState() => _CamerapageState();
}

class _CamerapageState extends State<Camerapage> {
  String backendIP = "192.168.1.34:8080";
  List<String> availableIPs = [
    '192.168.1.34:8080',
    '192.168.1.100:8080',
    '192.168.1.101:8080',
    '10.0.0.50:8080'
  ];

  void _onIpSelected(String ip) {
    setState(() {
      backendIP = ip;
    });
  }

  void _addIp(String newIp) {
    if (!availableIPs.contains(newIp) && newIp.isNotEmpty) {
      setState(() {
        availableIPs.add(newIp);
      });
    }
  }

  // IP seçme ve ekleme menüsünü gösteren metod
  void _showIpSelectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff2f3745),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Camera IP:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Divider(color: Colors.white24),
              ...availableIPs.map((ip) {
                return ListTile(
                  title: Text(
                    ip,
                    style: TextStyle(
                      color: backendIP == ip ? Colors.cyan : Colors.white,
                      fontWeight: backendIP == ip ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: backendIP == ip ? const Icon(Icons.wifi, color: Colors.cyan) : null,
                  onTap: () {
                    _onIpSelected(ip);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              const Divider(color: Colors.white24),
              ListTile(
                title: const Text(
                  '+ Add New IP',
                  style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  // IP ekleme formunu göstermek için ayrı bir dialog aç
                  Navigator.pop(context);
                  _showAddIpDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Yeni IP adresi ekleme dialog'u
  void _showAddIpDialog() {
    final TextEditingController ipController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xff2f3745),
          title: const Text('Add New IP', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: ipController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Enter new IP address",
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.cyan)),
            ),
            TextButton(
              onPressed: () {
                _addIp(ipController.text);
                _onIpSelected(ipController.text); // Yeni eklenen IP'yi seç
                Navigator.of(context).pop();
              },
              child: const Text('Add', style: TextStyle(color: Colors.cyan)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff101828),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 4,
                child: MjpegView(
                  uri: "http://$backendIP/stream",
                  errorWidget: (context) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xff2f3745),
                            radius: 40,
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: Color(0xffc0c3c7),
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Live Camera Feed",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text("Connected to $backendIP",style: TextStyle(color: Colors.grey.shade600),),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent,foregroundColor: Colors.white,shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(100))),
                            onPressed: () {
                              setState(() {
                                backendIP = backendIP;
                              });
                            },
                            child: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: (){
                            print("Şimdilik Sadece Tıklama");
                          },
                          child: CamerapageButtons(backgroundColor: Colors.white, foregroundColor: Colors.cyan, circleIcon: Icons.image_outlined, text: "Media", containerBackground: Colors.white)),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap:capturePhoto,
                              child: Container(
                                alignment: Alignment.center,
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                  
                                ),
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.cyan,
                                  child: Icon(Icons.camera_alt_outlined,color: Colors.white,),
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Text("Photo",style: TextStyle(color: Colors.white),)
                          ],
                        ),
                        CamerapageButtons(backgroundColor: Colors.white, foregroundColor: Colors.cyan, circleIcon: Icons.videocam_outlined, text: "Video", containerBackground: Colors.white)
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          Positioned(
            top: 40,
            right: 20,
            child: FloatingActionButton(
              onPressed: _showIpSelectionSheet,
              backgroundColor: const Color(0xff2f3745),
              child: const Icon(Icons.language, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> capturePhoto() async {
    final res = await http.get(Uri.parse("http://$backendIP/capture_photo"));
    print(res.body);
  }
}


class CamerapageButtons extends StatelessWidget {
  final Color backgroundColor;
  final Color containerBackground;
  final Color foregroundColor;
  final IconData circleIcon;
  final String text;

  const CamerapageButtons({
    required this.backgroundColor,
    super.key, required this.foregroundColor, required this.circleIcon, required this.text, required this.containerBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
    
      decoration: BoxDecoration(
      color: containerBackground,
      borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0,bottom: 10),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: backgroundColor,
              child: Icon(circleIcon,color: foregroundColor,size: 40,),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0,right: 25,bottom: 10),
            child: Text(text,style: TextStyle(fontWeight: FontWeight.bold,color: foregroundColor,fontSize: 15),),
          )
        ],
      ),
    );
  }
}