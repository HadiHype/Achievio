class GroupInfo {
  List<dynamic>? admins;
  String? description;
  String? title;
  String? profilePic;
  bool? starred;
  bool? visible;
  int? index;
  bool? isArchived;
  String? groupID;

  GroupInfo({
    this.admins,
    this.description,
    this.title,
    this.profilePic,
    this.starred,
    this.visible,
    this.index,
    this.isArchived,
    this.groupID,
  });

  factory GroupInfo.fromMap(Map<String, dynamic> data) {
    return GroupInfo(
      admins: data['admins'],
      description: data['description'],
      title: data['title'],
      profilePic: data['profilePic'],
      starred: data['starred'],
      visible: data['visible'],
      index: data['index'],
      isArchived: data['isArchived'],
      groupID: data['groupID'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "admins": admins,
      "description": description,
      "title": title,
      "profilePic": profilePic,
      "starred": starred,
      "visible": visible,
      "index": index,
      "isArchived": isArchived,
      "groupID": groupID,
    };
  }
}
