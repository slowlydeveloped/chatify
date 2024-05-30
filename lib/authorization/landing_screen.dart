// Dependencies
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// Paths
import '/util/constants.dart';
import '/util/assets_manager.dart';
import '/providers/authentication_provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    chechAuthentication();
    super.initState();
  }

  void chechAuthentication() async {
    final authProvider = context.read<AuthenticationProvider>();
    bool isAuthenticated = await authProvider.chechAuthenticationState();

    navigate(isAuthenticated: isAuthenticated); 
  }

  navigate({required bool isAuthenticated}) {
    if (isAuthenticated) {
      Navigator.of(context).pushReplacementNamed(Constants.homeScreen);
    } else {
      Navigator.of(context).pushReplacementNamed(Constants.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
            height: 400,
            width: 200,
            child: Column(
              children: [
                LottieBuilder.asset(AssetManager.login),
                const LinearProgressIndicator()
              ],
            )),
      ),
    );
  }
}
