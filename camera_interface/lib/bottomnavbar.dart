import 'package:camera_interface/camera%20ui/camerapage.dart';
import 'package:camera_interface/homepage.dart';
import 'package:camera_interface/main.dart';
import 'package:camera_interface/camera%20ui/mainpage.dart';
import 'package:camera_interface/videoscreen.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';

class Bottomnavbar extends StatefulWidget {
  const Bottomnavbar({super.key});

  @override
  State<Bottomnavbar> createState() => _BottomnavbarState();
}

class _BottomnavbarState extends State<Bottomnavbar> {
  int secilenIndex=0;
  List<Widget> pageList=[Mainpage(),Camerapage(),CameraHome(),VideoPlayerScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageList[secilenIndex],
      bottomNavigationBar: modernBar(),
    );
  }

  FlashyTabBar modernBar() {
    return FlashyTabBar(items: [
      FlashyTabBarItem(icon: Icon(Icons.home), title: Text("Home",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19),),
      activeColor: Colors.cyan,
      inactiveColor: Colors.grey
      ),
      FlashyTabBarItem(icon: Icon(Icons.camera_alt_outlined), title: Text("Camera"),
      activeColor: Colors.cyan,
      inactiveColor: Colors.grey),
      
    FlashyTabBarItem(icon: Icon(Icons.video_camera_back_rounded), title: Text("Mediaplayer")),
    FlashyTabBarItem(icon: Icon(Icons.videocam_outlined), title: Text("Video",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19),),
      activeColor: Colors.cyan,
      inactiveColor: Colors.grey
      ),
    
    ], onItemSelected: (index){
       return setState(() {
        secilenIndex=index;
      });
    },
    selectedIndex: secilenIndex,
    backgroundColor:  Colors.white,
    showElevation: true,
    height: 55,
    );
  }
}