import 'package:drreportreader/com/ai/service/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:drreportreader/com/ai/service/globals.dart' as globals;

class GetCredits extends StatefulWidget {
  const GetCredits({super.key});

  @override
  State<GetCredits> createState() => _GetCreditsState();
}

class _GetCreditsState extends State<GetCredits> {
  TextEditingController creditsController = TextEditingController();
  // FocusNode focusNode = FocusNode();
  int moneyToPay = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 0,

        // backgroundColor: Colors.purple.shade300,
        title: Text("Get Credits"),
      ),
      body: Column(
        children: [
          ClipPath(
            clipper: CircularClipperBottom(),
            child: Container(
              height: 200,
              decoration: BoxDecoration(color: Colors.indigo),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    shape: CircleBorder(),
                    child: Icon(
                      Icons.mode_standby_rounded,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                  TextField(
                    controller: creditsController,
                    keyboardType: TextInputType.number,
                    showCursor: false,
                    textAlign: TextAlign.center,
                    // focusNode: focusNode,
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {
                        if (value.trim().isNotEmpty) {
                          moneyToPay = int.parse(value) * 3;
                        } else {
                          moneyToPay = 0;
                        }
                      });
                    },
                    decoration: InputDecoration(
                        hintStyle: TextStyle(
                          color: Colors.indigo.shade50,
                        ),
                        border: InputBorder.none,
                        hintText: "Enter Credits"),
                    style: TextStyle(
                        color: Colors.indigo.shade50,
                        fontWeight: FontWeight.w900,
                        fontSize: 40.0),
                  ),
                  Padding(padding: EdgeInsets.all(20.0))
                ],
              ),
            ),
          ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Get now for",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              Padding(padding: EdgeInsets.all(5.0)),
              MaterialButton(
                color: Colors.indigo,
                elevation: 6,
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                onPressed: () async {
                  int credits = int.parse(creditsController.text);
                  await firestoreService.setCredits(
                      _auth.currentUser!.uid, credits);

                  setState(() {
                    globals.credits = globals.credits + credits;
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  "Rs ${moneyToPay}",
                  style: TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade50),
                ),
              )
            ],
          )),
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0))),
            width: double.infinity,
            child: Text(
              "1 Credit = Rs 3",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.indigo.shade50, fontSize: 20.0),
            ),
          )
        ],
      ),
    );
  }
}

class CircularClipperBottom extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 2, size.height - 100, size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
