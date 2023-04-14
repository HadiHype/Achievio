import '../Navigation Pages/Home/Widgets/card_groups.dart';

List<bool> isStarred = List<bool>.filled(10, false);
List<bool> isVisible = List<bool>.filled(10, true);
List<bool> isArchived = List<bool>.filled(10, false);

List<String> titles = [
  "Friends",
  "Work",
  "School",
  "Hobbies",
  "Health",
  "Finance",
  "Travel",
  "Fitness",
  "Food",
  "Family",
];

List<String> subTitles = [
  "Let us get out chores done. Mom and dad won’t be happy if you don’t do your chores!",
  "Let us go out on a trip. I am sure you will have a lot of fun!",
  "We will work hard and get the job done. I am sure you will be happy with the results!",
  "Let us study hard and get good grades. I am sure you will be happy with the results!",
  "Let us do something fun. I am sure you will have a lot of fun!",
  "Let us eat healthy and exercise. I am sure you will be happy with the results!",
  "Let us save money and invest. I am sure you will be happy with the results!",
  "Let us go on a trip. I am sure you will have a lot of fun!",
  "Let us exercise and eat healthy. I am sure you will be happy with the results!",
  "We love to eat. Let us eat healthy and exercise. I am sure you will be happy with the results!"
];

List<int> tasksAssigned = [
  12,
  18,
  21,
  13,
  15,
  17,
  19,
  20,
  22,
  14,
];

bool defined = false;
List<GroupCard> groupCards = <GroupCard>[];
List<GroupCard> groupCardsArchived = <GroupCard>[];

String dropDownValue = 'default';
String dropDownValue2 = 'All';

List<String> usernames = [
  "Mom",
  "Dad",
  "Sister",
  "Brother",
  "Grandma",
  "Grandpa",
  "Aunt",
  "Uncle",
  "Cousin",
  "Youssef",
];

List<String> taskStatus = [
  "Mom assigned a task to you.",
  "Dad checked your task.",
  "Sister commented on your task.",
  "Brother reacted to your task.",
  "Deadline for your task is today. Don't forget to complete it!",
  "Grandma assigned a task to you.",
  "Grandpa checked your task.",
  "Aunt commented on your task.",
  "Uncle reacted to your task.",
  "Youssef reacted to your task.",
];

List<String> taskDate = [
  "2023-03-26 17:35:00",
  "2023-03-24 18:30:00",
  "2023-03-23 11:30:00",
  "2023-03-22 13:30:00",
  "2023-03-21 19:30:00",
  "2023-03-20 10:30:00",
  "2023-03-19 09:30:00",
  "2023-03-18 10:30:00",
  "2023-03-17 12:30:00",
  "2023-03-16 13:30:00",
];

// List<UserData> users = [
//   UserData(
//     uid: "1",
//     name: "Mom",
//     email: "mom@mail.com",
//     phone: "123456789",
//   ),
//   UserData(
//     uid: "2",
//     name: "Dad",
//     email: "dad@mail.com",
//     phone: "123456789",
//   ),
//   UserData(
//     uid: "3",
//     name: "Sister",
//     email: "sister@mail.com",
//     phone: "123456789",
//   ),
//   UserData(
//     uid: "4",
//     name: "Brother",
//     email: "123456789",
//     phone: "123456789",
//   ),
//   UserData(
//     uid: "5",
//     name: "Grandma",
//     email: "grandpa@mail.com",
//     phone: "123456789",
//   ),
// ];
