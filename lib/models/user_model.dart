import '../util/constants.dart';

class UserModel {
  String uId;
  String name;
  String phoneNumber;
  String image;
  String token;
  String lastSeen;
  String aboutMe;
  String createdAt;
  bool isOnline;
  List<String> friendsUids;
  List<String> friendRequestUids;
  List<String> sentFriendRequestUids;

  UserModel({
    required this.uId,
    required this.name,
    required this.phoneNumber,
    required this.image,
    required this.token,
    required this.lastSeen,
    required this.aboutMe,
    required this.createdAt,
    required this.isOnline,
    required this.friendsUids,
    required this.friendRequestUids,
    required this.sentFriendRequestUids,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uId: map[Constants.uid] ?? '',
      name: map[Constants.name] ?? '',
      phoneNumber: map[Constants.phoneNumber] ?? '',
      image: map[Constants.image] ?? '',
      token: map[Constants.token] ?? '',
      lastSeen: map[Constants.lastSeen] ?? '',
      aboutMe: map[Constants.aboutMe] ?? '',
      createdAt: map[Constants.createdAt] ?? '',
      isOnline: map[Constants.isOnline] ?? false,
      friendsUids: List<String>.from(map[Constants.friendsUids] ?? []),
      friendRequestUids:
          List<String>.from(map[Constants.friendRequestUids] ?? []),
      sentFriendRequestUids:
          List<String>.from(map[Constants.sentFriendRequestUids] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constants.uid: uId,
      Constants.name: name,
      Constants.phoneNumber: phoneNumber,
      Constants.image: image,
      Constants.token: token,
      Constants.aboutMe: aboutMe,
      Constants.lastSeen: lastSeen,
      Constants.createdAt: createdAt,
      Constants.isOnline: isOnline,
      Constants.friendsUids: friendsUids,
      Constants.friendRequestUids: friendRequestUids,
      Constants.sentFriendRequestUids: sentFriendRequestUids
    };
  }
}
