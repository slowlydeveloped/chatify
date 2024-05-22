import 'package:chatify/main_screen/chat_list_screen.dart';
import 'package:chatify/main_screen/group_list_Screen.dart';
import 'package:chatify/main_screen/people_list_screen.dart';

import '../util/assets_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;

  @override
  void dispose() {
    pageController
        .dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chatify"),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(AssetManager.userImage),
            ),
          )
        ],
      ),
      body: PageView(
        controller: pageController, // Use the state-level PageController
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: const [
          ChatListScreen(),
          GroupListScreen(),
          PeopleListScreen()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble_2_fill), label: 'Chats'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.group), label: 'Groups'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.globe), label: 'People'),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          pageController.animateToPage(index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn);
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
