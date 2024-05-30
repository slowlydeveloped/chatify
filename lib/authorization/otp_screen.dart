// Dependencies
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

// Paths
import '../util/constants.dart';
import '/providers/authentication_provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  String? otpCode;
  @override
  Widget build(BuildContext context) {
    
    //get the arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final verificationId = args[Constants.verificationId] as String;
    final phoneNumber = args[Constants.phoneNumber] as String;

    final authProvider = context.watch<AuthenticationProvider>();

    final defaultPinTheme = PinTheme(
        width: 56,
        height: 60,
        textStyle: GoogleFonts.openSans(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.transparent)));
    return Scaffold(
        body: SafeArea(
      child: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Text(
              "Verification",
              style: GoogleFonts.openSans(
                  fontSize: 28, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 50),
            Text(
              "Enter the six digit code sent to the number",
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                  fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Text(
              phoneNumber,
              style: GoogleFonts.openSans(
                  fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 68,
              child: Pinput(
                length: 6,
                controller: controller,
                focusNode: focusNode,
                defaultPinTheme: defaultPinTheme,
                onCompleted: (pin) {
                  setState(() {
                    otpCode = pin;
                  });
                  // verify the otp code
                  verifyOTPCode(
                      verificationId: verificationId, otpCode: otpCode!);
                },
                focusedPinTheme: defaultPinTheme.copyWith(
                    height: 68,
                    width: 64,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.deepPurple))),
                errorPinTheme: defaultPinTheme.copyWith(
                    height: 68,
                    width: 64,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.red))),
              ),
            ),
            const SizedBox(height: 30),
            authProvider.isLoading
                ? const CircularProgressIndicator()
                : const SizedBox.shrink(),
            authProvider.isSuccessful
                ? Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                        color: Colors.green, shape: BoxShape.circle),
                    child: const Icon(
                      Icons.done,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                : const SizedBox.shrink(),
            authProvider.isLoading
                ? const SizedBox.shrink()
                : Text(
                    "Didn't get the code?",
                    style: GoogleFonts.openSans(fontSize: 16),
                  ),
            const SizedBox(height: 10),
            authProvider.isLoading
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () {
                      //TODO: resend OTP Screen
                    },
                    child: Text(
                      "Resend Code",
                      style: GoogleFonts.openSans(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ))
          ],
        ),
      )),
    ));
  }

  void verifyOTPCode({
    required String verificationId,
    required String otpCode,
  }) async {
    final authProvider = context.read<AuthenticationProvider>();
    authProvider.verifyOtpCode(
        verificationId: verificationId,
        otpCode: otpCode,
        context: context,
        onSuccess: () async {
          //  1. Check if the user is exists in the firestore
          bool userExists = await authProvider.checkIfUserExists();
          //  2. If the user exists,
          if (userExists) {
            //  2.a get user information
            await authProvider.getUserDataFromFirestore();
            //  2.b save user information to provider/ shared prefrences.
            await authProvider.saveUserDataToSharedPrefrences();
            // 2.c  move him to the homescreen
            navigate(userExists: true);
          } else {
            //  3. if not, then move him to the userinfo screen.
            navigate(userExists: false);
          }
        });
  }

  void navigate({required bool userExists}) {
    if (userExists) {
      // Navigate to home screen and remove all the previous routes
      Navigator.pushNamedAndRemoveUntil(
          context, Constants.homeScreen, (route) => false);
    } else {
      // Navigate to user info screen
      Navigator.pushNamed(context, Constants.userInformationScreen);
    }
  }
}
