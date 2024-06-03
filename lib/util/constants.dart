class Constants {
// Routes
  static const String loginScreen = '/loginScreen';
  static const String otpScreen = '/otpScreen';
  static const String homeScreen = '/homeScreen';
  static const String chatScreen = '/chatScreen';
  static const String profileScreen = '/profileScreen';
  static const String userInformationScreen = '/userInformationScreen';
  static const String groupListScreen = '/groupListScreen';
  static const String peopleListScreen = '/peopleListScreen';
  static const String settingsScreen = '/settingsScreen';
  static const String landingScreen = '/landingScreen';
  static const String userProfileScreen = '/userProfileScreen';
  static const String friendListScreen = '/friendListScreen';
  static const String friendRequestListScreen = '/friendRequestListScreen';

// UserModel
  static const String uid = 'uid';
  static const String name = 'name';
  static const String phoneNumber = 'phoneNumber';
  static const String image = 'image';
  static const String token = 'token';
  static const String lastSeen = 'lastSeen';
  static const String aboutMe = 'aboutMe';
  static const String createdAt = 'createdAt';
  static const String isOnline = 'isOnline';
  static const String friendsUids = 'friendsUids';
  static const String friendRequestUids = 'friendRequestUids';
  static const String sentFriendRequestUids = 'sentFriendRequestUids';

  static const String verificationId = 'verificationId';

  static const String users = 'users';
  static const String userModel = 'userModel';
  static const String userImages = 'userImages';
}

enum FriendViewType{
  friends,
  friendRequests,
  groupView,
}