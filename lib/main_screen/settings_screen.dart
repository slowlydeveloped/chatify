// Dependencies
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Paths
import '../providers/authentication_provider.dart';
import '../util/constants.dart';
import '../widgets/app_bar_back_button.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isDarkMode = false;
  void getThemeMode() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    if (savedThemeMode == AdaptiveThemeMode.dark) {
      setState(() {
        isDarkMode = true;
      });
    } else {
      isDarkMode = false;
    }
  }

  @override
  void initState() {
    getThemeMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;

//  Get uid from the arguments
    final uid = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: () {
          Navigator.of(context).pop();
        }),
        centerTitle: true,
        title: const Text("Settings"),
        actions: [
          currentUser.uId == uid
              ?
              // logout button
              IconButton(
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Logout"),
                            content:
                                const Text("Are yoiu sure you want to logout?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                  onPressed: () async {
                                    await context
                                        .read<AuthenticationProvider>()
                                        .logout()
                                        .whenComplete(() {
                                      Navigator.of(context).pop();
                                      Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          Constants.loginScreen,
                                          (route) => false);
                                    });
                                  },
                                  child: const Text("Logout"))
                            ],
                          );
                        });
                  },
                  icon: const Icon(Icons.logout))
              : const SizedBox.shrink()
        ],
      ),
      body: Center(
        child: Card(
          child: SwitchListTile(
            title: const Text("Change Theme"),
            secondary: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              child: Icon(
                isDarkMode
                    ? Icons.nightlight_round_rounded
                    : Icons.wb_sunny_rounded,
                color: isDarkMode ? Colors.black : Colors.white,
              ),
            ),
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
              });
              if (value) {
                AdaptiveTheme.of(context).setDark();
              } else {
                AdaptiveTheme.of(context).setLight();
              }
            },
          ),
        ),
      ),
    );
  }
}
