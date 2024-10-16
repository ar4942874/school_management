import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.height,
      required this.width,
      required this.color,
      required this.callback,
      required this.borderRadius,
      this.shape = BoxShape.rectangle,
      required this.text,
      required this.fontSize,
      required this.fontWeight,
      this.icon,  this.textColor=Colors.black});
  final double height;
  final double width;
  final Color color;
  final VoidCallback callback;
  final double borderRadius;
  final BoxShape shape;
  final String text;
  final double fontSize;
  final fontWeight; 
  final Color textColor;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          shape: shape,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon ?? const SizedBox(),
            const SizedBox(
              width: 15,
            ),
            Center(
              child: Text(
                text,
                style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
