class User {
  final String uid;
  final String name;
  final String email;
  final String phone;

  User(
      {required this.uid,
      required this.name,
      required this.email,
      required this.phone});

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
        uid: data['uid'],
        name: data['name'],
        email: data['email'],
        phone: data['phone']);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  @override
  String toString() {
    return 'User{uid: $uid, name: $name, email: $email, phone: $phone}';
  }
}
