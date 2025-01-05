import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class StaffProfile extends StatelessWidget {
  const StaffProfile(
      {super.key,
      required this.width,
      required this.height,
      required this.imageUrl,
      required this.name,
      required this.className});
  final double width;
  final double height;
  final String name;
  final String className;
  final String imageUrl;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(boxShadow: const [
          BoxShadow(
              offset: Offset(0, 7),
              blurRadius: 5,
              spreadRadius: 1,
              color: Colors.grey)
        ], borderRadius: BorderRadius.circular(12), color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text("Class $className"),
          ],
        ),
      ),
    );
  }
}

class StaffFeatures extends StatelessWidget {
  const StaffFeatures(
      {super.key,
      required this.title,
      required this.screenHeight,
      required this.screenWidth,
      required this.icon, required this.onTap,});
  final String title;
  final double screenHeight;
  final double screenWidth;
  final Icon icon;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector( 
      onTap: () {
        onTap();
      },
      child: Container(
        width: screenWidth * 0.35,
        height: screenHeight * 0.17,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              offset: Offset.fromDirection(1),
              blurRadius: 1,
              blurStyle: BlurStyle.inner)
        ], color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: screenWidth * 0.2,
                height: screenHeight * 0.1,
                decoration: BoxDecoration(boxShadow: const [
                ], shape: BoxShape.circle, color: Colors.blue.withOpacity(0.2)),
                child: icon),
            AutoSizeText(
              title,
              maxLines: 2,
              maxFontSize: 20,
              minFontSize: 12,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
