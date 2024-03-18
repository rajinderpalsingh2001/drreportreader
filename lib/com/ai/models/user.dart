import 'package:cloud_firestore/cloud_firestore.dart';

class user {
  String? name;
  String? email;
  int? credits;
  Timestamp? registeredOn;
  Timestamp? lastOpened;

  user.toObj(Map<String, dynamic> mp) {
    this.name = mp["name"];
    this.email = mp["email"];
    this.credits = mp["credits"];
    this.registeredOn = mp["registeredOn"];
    this.lastOpened = mp["lastOpened"];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> mp = {};
    mp["name"] = this.name;
    mp["email"] = this.email;
    mp["credits"] = this.credits;
    mp["registeredOn"] = this.registeredOn;
    mp["lastOpened"] = this.lastOpened;
    return mp;
  }
}
