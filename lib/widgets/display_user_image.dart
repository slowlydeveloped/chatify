// Dependencies
import 'dart:io';
import 'package:flutter/material.dart';

// Paths
import '../util/assets_manager.dart';

class DisplayUserImage extends StatelessWidget {
  const DisplayUserImage(
      {super.key,
      required this.finalFileImage,
      required this.radius,
      required this.onPressed});
  final File? finalFileImage;
  final double radius;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return finalFileImage == null
        ? Stack(
            children: [
               CircleAvatar(
                  radius: radius,
                  backgroundImage: const AssetImage(AssetManager.userImage)),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: InkWell(
                    onTap: onPressed,
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              )
            ],
          )
        : Stack(
            children: [
              CircleAvatar(
                radius: radius,
                backgroundImage: FileImage(File(finalFileImage!.path)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: onPressed,
                  child:  CircleAvatar(
                    radius: 15,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              )
            ],
          );
  }
}
