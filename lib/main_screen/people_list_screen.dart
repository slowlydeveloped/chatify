import 'package:chatify/providers/authentication_provider.dart';
import 'package:chatify/util/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../util/constants.dart';

class PeopleListScreen extends StatefulWidget {
  const PeopleListScreen({super.key});

  @override
  State<PeopleListScreen> createState() => _PeopleListScreenState();
}

class _PeopleListScreenState extends State<PeopleListScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: CupertinoSearchTextField(
                placeholder: "Search",
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: context
                    .read<AuthenticationProvider>()
                    .getAllUserStream(userId: currentUser.uId),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Failed to Load Data"),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No Users Found",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.openSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2),
                      ),
                    );
                  }
                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      final data =
                          document.data()! as Map<String, dynamic>;
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                              context, Constants.userProfileScreen,
                              arguments: data[Constants.uid]);
                        },
                        child: ListTile(
                          leading: userImageWidget(
                            imageUrl: data[Constants.image],
                            radius: 20,
                            onTap: () {},
                          ),
                          title: Text(data[Constants.name]),
                          subtitle: Text(
                            data[Constants.aboutMe],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
