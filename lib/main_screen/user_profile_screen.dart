// Dependencies
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Paths
import '../models/user_model.dart';
import '../providers/authentication_provider.dart';
import '../widgets/app_bar_back_button.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
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
                IconButton(onPressed: () {}, icon: const Icon(Icons.logout))
                : const SizedBox.shrink()
          ],
        ),
        body: StreamBuilder(
          stream:
              context.read<AuthenticationProvider>().userStream(userId: uid),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final userModel = UserModel.fromMap(
                snapshot.data!.data() as Map<String, dynamic>);
            return ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(userModel.image),
              ),
              title: Text(userModel.name),
              subtitle: Text(userModel.aboutMe),
            );
          },
        ));
  }
}
