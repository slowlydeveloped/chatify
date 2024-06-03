import 'package:chatify/models/user_model.dart';
import 'package:chatify/providers/authentication_provider.dart';
import 'package:chatify/util/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../util/constants.dart';

class FriendsList extends StatelessWidget {
  const FriendsList({super.key, required this.viewType});

  final FriendViewType viewType;
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uId;
    final future = viewType == FriendViewType.friends
        ? context.read<AuthenticationProvider>().getFriendsList(uid)
        : viewType == FriendViewType.friendRequests
            ? context.read<AuthenticationProvider>().getFriendsRequestList(uid)
            : context.read<AuthenticationProvider>().getFriendsList(uid);
    return FutureBuilder<List<UserModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No friends yet"));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final data = snapshot.data![index];
              return ListTile(
                contentPadding: const EdgeInsets.only(left: -10),
                leading: userImageWidget(
                    imageUrl: data.image,
                    radius: 30,
                    onTap: () {
                      Navigator.pushNamed(context, Constants.userProfileScreen,
                          arguments: data.uId);
                    }),
                title: Text(data.name),
                subtitle: Text(
                  data.aboutMe,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                    if (viewType == FriendViewType.friends) {
                      // TODO: Navigate to chat screen
                    } else if (viewType == FriendViewType.friendRequests) {
                      await context
                          .read<AuthenticationProvider>()
                          .acceptFriendRequest(friendUid: data.uId)
                          .whenComplete(() {
                        showSnackBar(
                            context, "You are now friends with ${data.name}");
                      });
                    }
                  },
                  child: viewType == FriendViewType.friends
                      ? const Text("Chat")
                      : const Text("Accept Request "),
                ),
              );
            },
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
