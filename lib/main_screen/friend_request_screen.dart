import 'package:chatify/widgets/app_bar_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../util/constants.dart';
import '../widgets/friends_list.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key});

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: () {
          Navigator.of(context).pop();
        }),
        title: const Text("Friend's List"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CupertinoSearchTextField(
              placeholder: "Search",
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {},
            ),
            const Expanded(
              child: FriendsList(
                viewType: FriendViewType.friendRequests,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
