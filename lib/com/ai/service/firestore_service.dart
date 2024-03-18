import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class FirestoreService {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseFirestore getFirestoreInstance() {
    return firestore;
  }

  Future<user> getUserDetails(String uid) async {
    user? userDetails;
    await firestore.collection("users").doc(uid).get().then((value) {
      userDetails = user.toObj(value.data()!);
    }).onError((error, stackTrace) {
      print(error);
    });
    return userDetails ?? user.toObj({});
  }

  Future<bool> setCredits(String uid, int credits) async {
    bool isDone = false;
    await firestore
        .collection("users")
        .doc(uid)
        .update({"credits": FieldValue.increment(credits)}).then((value) {
      isDone = true;
    });
    return isDone;
  }

  Future<bool> decrementCredits(String uid) async {
    bool isDone = false;
    await firestore
        .collection("users")
        .doc(uid)
        .update({"credits": FieldValue.increment(-1)}).then((value) {
      isDone = true;
    });
    return isDone;
  }

  Future<int> getCredits(String uid) async {
    int credits = 0;
    await firestore.collection("users").doc(uid).get().then((value) {
      credits = value.get("credits");
    });
    return credits;
  }

  Future<bool> registerUser(String uid, user userData) async {
    bool isSuccess = false;
    await firestore
        .collection("users")
        .doc(uid)
        .set(userData.toMap())
        .then((value) {
      isSuccess = true;
    }).onError((error, stackTrace) {
      isSuccess = false;
    });

    return isSuccess;
  }

  Future updateLastOpened(String uid) async {
    await firestore
        .collection("users")
        .doc(uid)
        .update({"lastOpened": Timestamp.fromDate(DateTime.now())});
  }
}
