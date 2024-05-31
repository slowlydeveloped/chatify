// Dependencies
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Paths
import '../models/user_model.dart';
import '../util/constants.dart';
import '../util/global_methods.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccessful = false;
  String? _uid;
  String? _phoneNumber;
  UserModel? _userModel;

  bool get isLoading => _isLoading;
  bool get isSuccessful => _isSuccessful;
  String? get uid => _uid;
  String? get phoneNumber => _phoneNumber;
  UserModel? get userModel => _userModel;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Check authentication state of the user
  Future<bool> chechAuthenticationState() async {
    bool isSignedIn = false;
    await Future.delayed(const Duration(seconds: 2));
    if (_auth.currentUser != null) {
      _uid = _auth.currentUser!.uid;

      // get user data from the fireStore
      await getUserDataFromFirestore();

      // save the user data in Shared Preferences
      await saveUserDataToSharedPrefrences();
      notifyListeners();
      isSignedIn = true;
    } else {
      isSignedIn = false;
    }
    return isSignedIn;
  }

  // Check if the user exists in the firestore
  Future<bool> checkIfUserExists() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();

    if (documentSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  // get user data from the firestore
  Future<void> getUserDataFromFirestore() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();
    _userModel =
        UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);

    notifyListeners();
  }

  // Save user data in Shared prefrences
  Future<void> saveUserDataToSharedPrefrences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.userModel, jsonEncode(userModel!.toMap()));
  }

  // Get user data from Shared prefrences
  Future<void> getUserDataFromSharedPrefrences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userModelString = prefs.getString(Constants.userModel) ?? " ";
    _userModel = UserModel.fromMap(jsonDecode(userModelString));
    _uid = userModel!.uId;
    notifyListeners();
  }

  // Sign in with phone number
  Future<void> signInWithPhoneNumber(
      {required String phoneNumber, required BuildContext context}) async {
    _isLoading = true;
    notifyListeners();

    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential).then((value) async {
            _uid = value.user!.uid;
            _phoneNumber = value.user!.phoneNumber;
            _isLoading = false;
            _isSuccessful = true;
            notifyListeners();
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          _isSuccessful = false;
          _isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.message!)));
        },
        codeSent: (String verificationId, int? resendToken) async {
          _isLoading = false;
          notifyListeners();

          Navigator.of(context).pushNamed(Constants.otpScreen, arguments: {
            Constants.verificationId: verificationId,
            Constants.phoneNumber: phoneNumber
          });
          print("Navigate to OTP screen");
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Code Sent")));
        },
        codeAutoRetrievalTimeout: (String verificationId) {});
  }

  Future<void> verifyOtpCode({
    required String verificationId,
    required String otpCode,
    required BuildContext context,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    final credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: otpCode);

    await _auth.signInWithCredential(credential).then((value) async {
      _uid = value.user!.uid;
      _phoneNumber = value.user!.phoneNumber;
      _isSuccessful = true;
      _isLoading = false;
      onSuccess();
      notifyListeners();
    }).catchError((e) {
      _isLoading = false;
      _isSuccessful = false;
      notifyListeners();
      showSnackBar(context, e.toString());
    });
  }

  // Save user data in firestore
  void saveUserDatatoFirestore({
    required UserModel userModel,
    required File? fileImage,
    required Function onSuccess,
    required Function onFailure,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (fileImage != null) {
        String imageUrl = await storeFiletoStore(
            file: fileImage,
            refernce: "${Constants.userImages}/ ${Constants.uid}");
        userModel.image = imageUrl;
      }

      userModel.lastSeen = DateTime.now().microsecondsSinceEpoch.toString();
      userModel.createdAt = DateTime.now().microsecondsSinceEpoch.toString();

      _userModel = userModel;
      _uid = userModel.uId;
      // Save User data to firestore
      await _firestore
          .collection(Constants.users)
          .doc(userModel.uId)
          .set(userModel.toMap());

      _isLoading = false;
      onSuccess();
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFailure(e.toString());
    }
  }

  // Store file to storage and obtain ifileUrl
  Future<String> storeFiletoStore({
    required File file,
    required String refernce,
  }) async {
    UploadTask uploadTask = _storage.ref(refernce).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String fileUrl = await taskSnapshot.ref.getDownloadURL();
    return fileUrl;
  }

  // get user stream
  Stream<DocumentSnapshot> userStream({required String userId}) {
    return _firestore.collection(Constants.users).doc(userId).snapshots();
  }

  // get all user stream
  Stream<QuerySnapshot> getAllUserStream({required String userId}) {
    return _firestore
        .collection(Constants.users)
        .where(Constants.uid, isNotEqualTo: userId)
        .snapshots();
  }

// Function to send friend request to the friend with userID.
  Future<void> sendFriendRequest({required String friendUid}) async {
    try {
      // add our uid to friend request list
      await _firestore.collection(Constants.users).doc(friendUid).update({
        Constants.friendRequestUids: FieldValue.arrayUnion([_uid]),
      });
      // add friend uid to our sent friend request lists
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sentFriendRequestUids: FieldValue.arrayUnion([friendUid])
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  // // Function to Cancel friend request to the friend with userID.

  Future<void> cancelFriendRequest({required String friendUid}) async {
    try {
      // add our uid to friend request list
      await _firestore.collection(Constants.users).doc(friendUid).update({
        Constants.friendRequestUids: FieldValue.arrayRemove([_uid]),
      });
      // add friend uid to our sent friend request lists
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sentFriendRequestUids: FieldValue.arrayRemove([friendUid])
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  // Function to accept the friend request
  Future<void> acceptFriendRequest({required String friendUid}) async {
    // add our UID to the friend's list.
    await _firestore.collection(Constants.users).doc(friendUid).update({
      Constants.friendsUids: FieldValue.arrayUnion([_uid])
    });

    // add the friend's UID to our friends list.
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendsUids: FieldValue.arrayUnion([friendUid])
    });

    // remove our uid from friend's request list.
    await _firestore.collection(Constants.users).doc(friendUid).update({
      Constants.sentFriendRequestUids: FieldValue.arrayRemove([_uid])
    });

    // remove friend uid from our  friend's request list.
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.sentFriendRequestUids: FieldValue.arrayRemove([friendUid])
    });
  }

  // Function to remove friends from our friends list
  Future<void> removeFriend({required String friendId}) async {

    // Cammand to remove our uid from the friend's list.
    await _firestore.collection(Constants.users).doc(friendId).update({
      Constants.friendsUids: FieldValue.arrayRemove([_uid])
    });

     // Cammand to remove friend's uid from our friend's list.
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendsUids: FieldValue.arrayRemove([friendId])
    });
  }

// Function to logout the user from the device.
  Future logout() async {
    await _auth.signOut();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    notifyListeners();
  }
}
