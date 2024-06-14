import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
  @override
  Widget build(BuildContext context) {
    // Retrieve the current user from the authentication provider
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    // Get the UID of the profile being viewed from the route arguments
    final uid = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: () {
          Navigator.of(context).pop();
        }),
        centerTitle: true,
        title: const Text("Profile"),
        actions: [
          // Show settings icon if the profile being viewed belongs to the current user
          currentUser.uId == uid
              ? IconButton(
                  onPressed: () async {
                    await Navigator.pushNamed(context, Constants.settingsScreen,
                        arguments: uid);
                  },
                  icon: const Icon(Icons.settings))
              : const SizedBox.shrink()
        ],
      ),
      body: StreamBuilder(
        // Stream the user data from Firestore
        stream: context.read<AuthenticationProvider>().userStream(userId: uid),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Parse the user data from the snapshot
          final userModel =
              UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              children: [
                // Display the user's profile image
                userImageWidget(
                    radius: 60, onTap: () {}, imageUrl: userModel.image),
                const SizedBox(height: 10),
                // Display the user's name
                Text(
                  userModel.name,
                  style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Display the user's phone number if the profile belongs to the current user
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
                // Build the friend request button
                buildFriendRequestButton(
                    currentUser: currentUser, userModel: userModel),
                const SizedBox(height: 10),
                // Build the view friend button
                buildViewFriendButton(
                    currentUser: currentUser, userModel: userModel),
                const SizedBox(height: 10),
                // Display the "About Me" section
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
                // Display the user's "About Me" text
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

  // Function to build the friend request button based on the relationship status
  Widget buildFriendRequestButton({
    required UserModel currentUser,
    required UserModel userModel,
  }) {
    if (currentUser.uId == userModel.uId &&
        userModel.friendRequestUids.isNotEmpty) {
      return customElevatedButton(
          width: MediaQuery.of(context).size.width * 0.7,
          onPressed: () {
            Navigator.pushNamed(context, Constants.friendRequestListScreen);
          },
          label: "View Friend Requests",
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).primaryColor);
    } else {
      return const SizedBox.shrink();
    }
  }

  // Function to build the view friend button based on the relationship status
  Widget buildViewFriendButton({
    required UserModel currentUser,
    required UserModel userModel,
  }) {
    if (currentUser.uId == userModel.uId) {
      return customElevatedButton(
          width: MediaQuery.of(context).size.width * 0.7,
          onPressed: () {
            Navigator.pushNamed(context, Constants.friendListScreen);
          },
          label: "View Friends",
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).primaryColor);
    } else if (userModel.friendsUids.contains(currentUser.uId)) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          customElevatedButton(
              width: MediaQuery.of(context).size.width * 0.4,
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Unfriend"),
                        content: Text(
                          "Are yoiu sure you want to nfriend ${userModel.name}?",
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await context
                                    .read<AuthenticationProvider>()
                                    .removeFriend(friendId: userModel.uId)
                                    .whenComplete(() {
                                  showSnackBar(context,
                                      "You're no longer friends with ${userModel.name}");
                                });
                              },
                              child: const Text("Unfriend"))
                        ],
                      );
                    });
              },
              label: "Unfriend",
              backgroundColor:
                  Theme.of(context).buttonTheme.colorScheme!.primary,
              textColor: Colors.white),
          customElevatedButton(
              width: MediaQuery.of(context).size.width * 0.4,
              onPressed: () {
                // Navigate to chat screen with following arguments :
                // 1. friend uid, friend name, friend image and group string
                Navigator.pushNamed(context, Constants.chatScreen, arguments: [
                  userModel.uId,
                  userModel.name,
                  userModel.image,
                  '',
                ]);
              },
              label: "Chat",
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).primaryColor),
        ],
      );
    } else if (userModel.friendRequestUids.contains(currentUser.uId)) {
      return customElevatedButton(
          width: MediaQuery.of(context).size.width * 0.7,
          onPressed: () async {
            await context
                .read<AuthenticationProvider>()
                .cancelFriendRequest(friendUid: userModel.uId)
                .whenComplete(() {
              showSnackBar(context, "Friend Request Cancelled");
            });
          },
          label: "Cancel Friend Request",
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).primaryColor);
    } else if (userModel.sentFriendRequestUids.contains(currentUser.uId)) {
      return customElevatedButton(
          width: MediaQuery.of(context).size.width * 0.7,
          onPressed: () async {
            await context
                .read<AuthenticationProvider>()
                .acceptFriendRequest(friendUid: userModel.uId)
                .whenComplete(() {
              showSnackBar(
                  context, "You are now friends with ${userModel.name}");
            });
          },
          label: "Accept Friend Request",
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).primaryColor);
    } else {
      return customElevatedButton(
          onPressed: () async {
            await context
                .read<AuthenticationProvider>()
                .sendFriendRequest(friendUid: userModel.uId)
                .whenComplete(() {
              showSnackBar(context, "Friend Request sent");
            });
          },
          label: "Send Friend Request",
          width: MediaQuery.of(context).size.width * 0.7,
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).primaryColor);
    }
  }

  // Function to create a custom elevated button
  Widget customElevatedButton(
      {required VoidCallback onPressed,
      required String label,
      required double width,
      required Color backgroundColor,
      required Color textColor}) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: onPressed,
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
