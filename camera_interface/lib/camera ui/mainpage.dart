import 'package:flutter/material.dart';

class Mainpage extends StatelessWidget {
  const Mainpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: const Color.fromARGB(255, 14, 13, 13),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          //Logo ve yazı
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image.asset("images/ilab2.jpg",height: MediaQuery.of(context).size.height*0.15,),
                Text("ILabApp",style: TextStyle(color: Colors.cyan,fontSize: 25,fontWeight: FontWeight.bold),),
                  SizedBox(height: 10,),
                Text("Capture your moments",style: TextStyle(color: Colors.grey.shade600),
                ),
                ],
            ),
          ),

          Container(
            child: Column(
              children: [
                HomepageButtons(backgroundColor: Colors.cyan.shade400, foregroundColor: Colors.white, circleIcon: Icons.camera_alt_outlined, text: "Take Photo", containerBackground: Colors.cyan),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                  HomepageButtons(backgroundColor: Colors.white, foregroundColor: Colors.cyan, circleIcon: Icons.videocam_outlined, text: "Record Video", containerBackground: Colors.white),
                  HomepageButtons(backgroundColor: Colors.white, foregroundColor: Colors.cyan, circleIcon: Icons.image_outlined, text: "View Gallery", containerBackground: Colors.white),
                  ],
                ),
                
              ],
            ),
          ),

          Text("Choose an option to get started",style: TextStyle(color: Colors.grey.shade600),)
        
        ],
      ),
    );
  }
}

class HomepageButtons extends StatelessWidget {
  final Color backgroundColor;
  final Color containerBackground;
  final Color foregroundColor;
  final IconData circleIcon;
  final String text;

  const HomepageButtons({
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
            padding: const EdgeInsets.only(top: 15.0,bottom: 10),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: backgroundColor,
              child: Icon(circleIcon,color: foregroundColor,size: 40,),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0,right: 20,bottom: 15),
            child: Text(text,style: TextStyle(fontWeight: FontWeight.bold,color: foregroundColor,fontSize: 15),),
          )
        ],
      ),
    );
  }
}