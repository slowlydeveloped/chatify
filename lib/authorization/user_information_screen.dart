// Dependencies

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

// Paths

import '../models/user_model.dart';
import '/util/global_methods.dart';
import '/widgets/display_user_image.dart';
import '/widgets/app_bar_back_button.dart';
import '/providers/authentication_provider.dart';
import '/util/constants.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final RoundedLoadingButtonController _buttonController =
      RoundedLoadingButtonController();
  final TextEditingController _nameController = TextEditingController();

  String userImage = " ";
  File? finalFileImage;
  @override
  void dispose() {
    _buttonController.stop();
    _nameController.dispose();
    super.dispose();
  }

  void selectImage(bool fromCamera) async {
    finalFileImage = await pickImageMethod(
        fromCamera: fromCamera,
        onFail: (String message) {
          showSnackBar(context, message);
        });
    // Crop Images
    await cropImage(finalFileImage?.path);
    popContext();
  }

  popContext() {
    Navigator.of(context).pop();
  }

  Future<void> cropImage(filepath) async {
    if (filepath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filepath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );
      if (croppedFile != null) {
        setState(() {
          finalFileImage = File(croppedFile.path);
        });
      }
    }
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height / 5,
        child: Column(
          children: [
            ListTile(
              onTap: () {
                selectImage(true);
         
              },
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
            ),
            ListTile(
              onTap: () {
                selectImage(false);
                
              },
              leading: const Icon(Icons.image),
              title: const Text("Gallery"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: () {
          Navigator.pop(context);
        }),
        centerTitle: true,
        title: Text("User Information", style: GoogleFonts.openSans()),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              DisplayUserImage(
                finalFileImage: finalFileImage,
                radius: 50,
                onPressed: () {
                  showBottomSheet();
                },
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                    hintText: "Enter your name",
                    labelText: "Enter your name",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)))),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: RoundedLoadingButton(
                  controller: _buttonController,
                  onPressed: () {
                    if (_nameController.text.isEmpty ||
                        _nameController.text.length < 3) {
                      showSnackBar(context, "Please Enter you name");
                      _buttonController.reset();
                      return;
                    }
                    // save ths user data in firestore
                    saveUserDataToFirestore();
                  },
                  successIcon: Icons.check,
                  successColor: Colors.green,
                  errorColor: Colors.red,
                  color: Colors.deepPurple,
                  child: Text(
                    "Continue",
                    style: GoogleFonts.openSans(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Save user data to firestore
  void saveUserDataToFirestore() async {
    final authProvider = context.read<AuthenticationProvider>();

    UserModel userModel = UserModel(
      uId: authProvider.uid!,
      name: _nameController.text.trim(),
      phoneNumber: authProvider.phoneNumber!,
      image: '',
      token: "",
      aboutMe: 'Hey there, I am using whatsapp.',
      lastSeen: "",
      createdAt: "",
      isOnline: true,
      friendRequestUids: [],
      friendsUids: [],
      sentFriendRequestUids: [],
    );

    authProvider.saveUserDatatoFirestore(
      userModel: userModel,
      fileImage: finalFileImage,
      onSuccess: () async {
        _buttonController.success();
        // save user data to shared prefrences
        await authProvider.saveUserDataToSharedPrefrences();
        navigateToHomeScreen();
      },
      onFailure: () async {
        _buttonController.error();
        showSnackBar(context, "Failed to save user data");
        await Future.delayed(const Duration(seconds: 1));
      },
    );
  }

//  Navigate to Home Screen
  void navigateToHomeScreen() {
    Navigator.of(context).pushReplacementNamed(Constants.homeScreen);
  }
}
