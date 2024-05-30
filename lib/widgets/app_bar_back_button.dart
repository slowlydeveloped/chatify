import 'dart:io';

import 'package:flutter/material.dart';

class AppBarBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  const AppBarBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
          Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios_new),
    );
  }
}
