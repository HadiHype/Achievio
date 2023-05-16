class UserData {
  String? uid;
  String? username;
  String? email;
  String? dateOfBirth;
  String? gender;
  String? profilePicture;
  List<dynamic> friends;
  List<dynamic> friendRequestReceived;
  List<dynamic> friendRequestSent;

  UserData({
    this.uid,
    this.username,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.profilePicture,
    this.friends = const [],
    this.friendRequestReceived = const [],
    this.friendRequestSent = const [],
  });

  factory UserData.fromMap(Map<String, dynamic> data) {
    return UserData(
      uid: data['uid'],
      username: data['username'],
      email: data['email'],
      gender: data['gender'],
      dateOfBirth: data['dateOfBirth'],
      profilePicture: data['profilePicture'],
      friends: data['friends'] ?? [],
      friendRequestReceived: data['friendRequestReceived'] ?? [],
      friendRequestSent: data['friendRequestSent'] ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "username": username,
      "email": email,
      "gender": gender,
      "dateOfBirth": dateOfBirth,
      "profilePicture": profilePicture,
      "friends": friends,
      "friendRequestReceived": friendRequestReceived,
      "friendRequestSent": friendRequestSent,
    };
  }
}
