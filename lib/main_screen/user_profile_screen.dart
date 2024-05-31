// Dependencies
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

// Paths
import '../models/user_model.dart';
import '../providers/authentication_provider.dart';
import '../util/global_methods.dart';
import '../widgets/app_bar_back_button.dart';
import '../util/constants.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  File? finalFileImage;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    // Get user data from arguments
    final uid = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: () {
          Navigator.of(context).pop();
        }),
        centerTitle: true,
        title: const Text("Profile"),
        actions: [
          currentUser.uId == uid
              ?
              // logout button
              IconButton(
                  onPressed: () async {
                    // Navigate to the setting screen with uid as arguments
                    await Navigator.pushNamed(context, Constants.settingsScreen,
                        arguments: uid);
                  },
                  icon: const Icon(Icons.settings))
              : const SizedBox.shrink()
        ],
      ),
      body: StreamBuilder(
        stream: context.read<AuthenticationProvider>().userStream(userId: uid),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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

          final userModel =
              UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              children: [
                userImageWidget(
                    radius: 60, onTap: () {}, imageUrl: userModel.image),
                const SizedBox(height: 10),
                Text(
                  userModel.name,
                  style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                currentUser.uId == userModel.uId
                    ? Text(
                        userModel.phoneNumber,
                        style: GoogleFonts.openSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 10),
                buildFriendRequestButton(
                    currentUser: currentUser, userModel: userModel),
                const SizedBox(height: 10),
                buildViewFriendButton(
                    currentUser: currentUser, userModel: userModel),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 40,
                      width: 40,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "About Me.",
                      style: GoogleFonts.openSans(
                          fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 40,
                      width: 40,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                Text(
                  userModel.aboutMe,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // Friend Request button
  Widget buildFriendRequestButton({
    required UserModel currentUser,
    required UserModel userModel,
  }) {
    if (currentUser.uId == userModel.uId &&
        userModel.friendRequestUids.isNotEmpty) {
      // We are in our profile
      return customElevatedButton(
        width: MediaQuery.of(context).size.width * 0.7,
        onPressed: () {},
        label: "View Friend Requests ",
      );
    } else {
      // Not in our profile
      return const SizedBox.shrink();
    }
  }

  // Friend List button
  Widget buildViewFriendButton({
    required UserModel currentUser,
    required UserModel userModel,
  }) {
    if (currentUser.uId == userModel.uId &&
        userModel.friendRequestUids.isNotEmpty) {
      // We are in our profile
      return customElevatedButton(
        width: MediaQuery.of(context).size.width * 0.7,
        onPressed: () {},
        label: "View Friends ",
      );
    } else {
      // Not in our profile then Show a send request button
      if (currentUser.uId != userModel.uId) {
        // show cancel friend request  text if the user has already sent the friend request.
        if (userModel.friendRequestUids.contains(currentUser.uId)) {
          return customElevatedButton(
              width: MediaQuery.of(context).size.width * 0.7,
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .cancelFriendRequest(friendUid: userModel.uId)
                    .whenComplete(() {
                  showSnackBar(context, " Friend Request Cancelled ");
                });
              },
              label: "Cancel Friend Request ");
        }
        // Show accept friend request text if the user has already sent the friend request.
        else if (userModel.sentFriendRequestUids.contains(currentUser.uId)) {
          return customElevatedButton(
              width: MediaQuery.of(context).size.width * 0.7,
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .acceptFriendRequest(friendUid: userModel.uId)
                    .whenComplete(() {
                  showSnackBar(
                      context, " You are now friends with ${userModel.name}");
                });
              },
              label: "Accept Friend Request");
        } else if (userModel.friendsUids.contains(currentUser.uId)) {
          return Row(
            children: [
              // Unfriend button
              customElevatedButton(
                  width: MediaQuery.of(context).size.width * 0.4,
                  onPressed: () async {
                    await context
                        .read<AuthenticationProvider>()
                        .removeFriend(friendId: userModel.uId)
                        .whenComplete(() {
                      showSnackBar(context,
                          "You're no longer friends with ${userModel.name}");
                    });
                  },
                  label: "Unfriend"),

              // Chat button
              customElevatedButton(
                  width: MediaQuery.of(context).size.width * 0.4,
                  onPressed: ()  {
                    // Navigate to chat screen.
                  },
                  label: "Send Message"),
            ],
          );
        }
        // Show send friend request text if the user has not sent the friend request.
        else {
          return customElevatedButton(
              width: MediaQuery.of(context).size.width * 0.7,
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .sendFriendRequest(friendUid: userModel.uId)
                    .whenComplete(() {
                  showSnackBar(context, "Friend Request sent");
                });
              },
              label: "Send Friend Request");
        }
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  // Custom Elevated Button
  Widget customElevatedButton({
    required VoidCallback onPressed,
    required String label,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
