import 'package:chatify/util/constants.dart';
import 'package:chatify/widgets/friends_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/app_bar_back_button.dart';

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: () {
          Navigator.of(context).pop();
        }),
        title: const Text("Friends"),
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
                viewType: FriendViewType.friends,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
