import '/util/assets_manager.dart';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../providers/authentication_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();

  Country selectedCountry = Country(
      phoneCode: '91',
      countryCode: 'IND',
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: 'India',
      example: 'India',
      displayName: 'India',
      displayNameNoCountryCode: 'IND',
      e164Key: '');

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 50),
              SizedBox(
                height: 200,
                width: 200,
                child: LottieBuilder.asset(AssetManager.login),
              ),
              Text(
                "Chatify",
                style: GoogleFonts.openSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Text("Add your phone number to verify",
                  style: GoogleFonts.openSans()),
              const SizedBox(height: 20),
              TextField(
                controller: phoneController,
                maxLength: 10,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    phoneController.text = value;
                  });
                },
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Phone Number',
                    hintStyle: GoogleFonts.openSans(
                        fontSize: 16, fontWeight: FontWeight.w500),
                    prefixIcon: Container(
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                      child: InkWell(
                        onTap: () {
                          showCountryPicker(
                              context: context,
                              showPhoneCode: true,
                              onSelect: (Country country) {
                                setState(() {
                                  selectedCountry = country;
                                });
                              });
                        },
                        child: Text(
                            '${selectedCountry.flagEmoji}  +${selectedCountry.phoneCode}',
                            style: GoogleFonts.openSans(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: phoneController.text.length > 9
                        ? authProvider.isLoading
                            ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(),
                            )
                            : InkWell(
                                onTap: () {
                                  //sign in with phone number 
                                  authProvider.signInWithPhoneNumber(
                                      phoneNumber:
                                          "+${selectedCountry.phoneCode}${phoneController.text}",
                                      context: context);
                                },
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  margin: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.done,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              )
                        : null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
