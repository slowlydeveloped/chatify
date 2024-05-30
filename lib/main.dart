//Dependencies
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Paths
import '/providers/authentication_provider.dart';
import '/firebase_options.dart';
import 'authorization/landing_screen.dart';
import 'authorization/user_information_screen.dart';
import '/authorization/login_screen.dart';
import '/authorization/otp_screen.dart';
import '/main_screen/chat_list_screen.dart';
import '/main_screen/group_list_screen.dart';
import '/main_screen/home_screen.dart';
import '/main_screen/people_list_screen.dart';
import '/main_screen/settings_screen.dart';
import 'main_screen/user_profile_screen.dart';
import 'util/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
      ],
      child: MyApp(savedThemeMode: savedThemeMode),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const MyApp({super.key, required this.savedThemeMode});
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurpleAccent,
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: theme,
        darkTheme: darkTheme,
        initialRoute: Constants.landingScreen,
        routes: {
          Constants.landingScreen: (context) => const LandingScreen(),
          Constants.loginScreen: (context) => const LoginScreen(),
          Constants.otpScreen: (context) => const OtpScreen(),
          Constants.userInformationScreen: (context) =>
              const UserInformationScreen(),
          Constants.settingsScreen: (context) => const SettingScreen(),
          Constants.groupListScreen: (context) => const GroupListScreen(),
          Constants.peopleListScreen: (context) => const PeopleListScreen(),
          Constants.chatScreen: (context) => const ChatListScreen(),
          Constants.homeScreen: (context) => const HomeScreen(),
          Constants.profileScreen: (context) => const SettingScreen(),
          Constants.userProfileScreen: (context) => const UserProfileScreen()
          
        },
      ),
    );
  }
}
