import 'dart:async';

import 'package:drreportreader/com/ai/service/api_service.dart';
import 'package:drreportreader/com/ai/service/firestore_service.dart';
import 'package:drreportreader/com/ai/views/Credits.dart';
import 'package:drreportreader/com/ai/widgets/credits_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_icons/flutter_animated_icons.dart';
import 'package:drreportreader/com/ai/service/globals.dart' as globals;

class ChatVirtualDoctor extends StatefulWidget {
  List<Map<String, String>> messages = [];
  ChatVirtualDoctor(this.messages);

  @override
  State<ChatVirtualDoctor> createState() =>
      _ChatVirtualDoctorState(this.messages);
}

class _ChatVirtualDoctorState extends State<ChatVirtualDoctor> {
  List<Map<String, String>> messages = [];
  _ChatVirtualDoctorState(this.messages);
  bool isTyping = false;
  bool isCreditUsed = false;

  TextEditingController userInputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<String> hintText = [
    "What should I do now?",
    "ab mai kya kru",
    "Ask to AI Doctor",
  ];
  int hintTextIndex = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirestoreService firestoreService = FirestoreService();

  Widget _userOrSystemInput(String userType, String message) {
    return Align(
      alignment:
          userType == "system" ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300.0),
        child: Card(
          color: userType == "system" ? Colors.indigo.shade100 : Colors.indigo,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
            topLeft: userType == "system"
                ? const Radius.circular(0.0)
                : const Radius.circular(10.0),
            bottomLeft: const Radius.circular(10.0),
            bottomRight: const Radius.circular(10.0),
            topRight: userType == "system"
                ? const Radius.circular(10.0)
                : const Radius.circular(0.0),
          )),
          child: Container(
              // width: 300,
              padding: const EdgeInsets.all(10.0),
              child: Text(
                message,
                textAlign:
                    userType == "system" ? TextAlign.left : TextAlign.right,
                style: TextStyle(
                    color: userType == "system"
                        ? Colors.indigo.shade900
                        : Colors.white),
              )),
        ),
      ),
    );
  }

  void sendMessageChat() async {
    setState(() {
      isTyping = true;
    });
    APIService obj = APIService();
    setState(() {
      messages.add({"role": "user", "content": userInputController.text});
    });
    await obj.analyseReportText(messages).then((value) {
      Map<String, dynamic> response = value;

      if (response["error"] == true) {
        messages.add({"role": "system", "content": response["message"]});
      } else {
        messages.add({"role": "system", "content": response["message"]});
      }
    });
    // messages.add({"role": "system", "content": "Ok sir i will do "});

    setState(() {
      messages;
      isTyping = false;
      isCreditUsed = false;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });

    Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        hintTextIndex = (hintTextIndex + 1) % hintText.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text("Virtual Doctor"),
        toolbarHeight: 80,
        elevation: 0,
        actions: [
          CreditsButton(globals.credits, () async {
            await Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => Credits()));
            setState(() {
              globals.credits;
            });
          })
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0))),
              alignment: Alignment.center,
              child: const Text(
                "You are engaging with the AI Chatbot for consultation. Our aim is to offer the most valuable assistance, though we cannot guarantee absolute accuracy and hold no liability for any inaccuracies in the diagnoses or outcomes produced by the AI. For precise advice, it is advisable to seek guidance from a medical professional.",
                textAlign: TextAlign.justify,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 8.0),
              ),
            ),
            Expanded(
                child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _userOrSystemInput(
                    messages[index]["role"]!, messages[index]["content"]!);
              },
            )),
            isTyping ? _userOrSystemInput("system", "Typing...") : Container(),
            Container(
              margin: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey), // Border color
                borderRadius: BorderRadius.circular(50.0), // Border radius
              ),
              child: Column(
                children: [
                  TextField(
                    controller: userInputController,
                    onChanged: (value) {
                      setState(() {
                        userInputController;
                      });
                    },
                    onSubmitted: (message) {
                      userInputController.clear();
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      );
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20.0),
                      hintText: hintText[hintTextIndex],
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: userInputController.text.trim() == ""
                              ? Colors.grey
                              : Colors.indigo,
                        ),
                        onPressed: () {
                          if (userInputController.text.trim() != "") {
                            if ((messages.length == 10 &&
                                    isCreditUsed == false) ||
                                ((messages.length - 10) % 20 == 0 &&
                                    isCreditUsed == false)) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0)),
                                      contentPadding: EdgeInsets.all(20.0),
                                      title: Text("Limit Exceeded"),
                                      content: Text(
                                          "Your message count for this report is ${messages.length}"),
                                      actions: [
                                        Align(
                                          alignment: Alignment.center,
                                          child: MaterialButton(
                                            color: Colors.indigo,
                                            shape: StadiumBorder(),
                                            onPressed: () async {
                                              await firestoreService
                                                  .decrementCredits(
                                                      _auth.currentUser!.uid)
                                                  .then((value) {
                                                setState(() {
                                                  globals.credits =
                                                      globals.credits - 1;
                                                  isCreditUsed = true;
                                                });
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "Use 1 credit & get 20 Messages",
                                              style: TextStyle(
                                                  color: Colors.indigo.shade50),
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  });
                            } else {
                              sendMessageChat();                          
                              userInputController.clear();
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
