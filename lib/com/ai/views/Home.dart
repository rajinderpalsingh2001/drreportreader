import 'package:drreportreader/com/ai/service/firestore_service.dart';
import 'package:drreportreader/com/ai/views/GetCredits.dart';
import 'package:drreportreader/com/ai/views/Login.dart';
import 'package:drreportreader/com/ai/views/ReportAnalysis.dart';
import 'package:drreportreader/com/ai/views/credits.dart';
import 'package:drreportreader/com/ai/widgets/credits_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drreportreader/com/ai/service/globals.dart' as globals;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController userInputController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // XFile? imageFile;
  FirestoreService firestoreService = FirestoreService();
  final Future<SharedPreferences> storage = SharedPreferences.getInstance();
  String user_name = "Dr. Report Reader";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    storage.then((pref) {
      setState(() {
        user_name = pref.getString("name")!;
      });
    });

    firestoreService.getCredits(_auth.currentUser!.uid).then((value) {
      setState(() {
        globals.credits = value;
      });
    });
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        // imageFile = pickedImage;
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ReportAnalysis(pickedImage)));
      }
    } catch (e) {
      // imageFile = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        toolbarHeight: 80,
        // backgroundColor: Colors.purple.shade300,
        title: Text("Dr. Report Reader"),
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
      drawer: Container(
        margin: EdgeInsets.all(30.0),
        child: Drawer(
          backgroundColor: Colors.indigo.shade50,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  // padding: EdgeInsets.zero,
                  padding: EdgeInsets.all(20.0),
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        user_name,
                        style: TextStyle(color: Colors.indigo),
                      ),
                      subtitle: Text(
                        _auth.currentUser!.email!,
                        style: TextStyle(color: Colors.indigo),
                      ),
                      trailing: IconButton(
                          onPressed: () {
                            _auth.signOut();
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => Login()));
                          },
                          icon: Icon(Icons.logout)),
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                    ListTile(
                        leading: Icon(
                          Icons.mode_standby_rounded,
                        ),
                        title: Text('Get Credits'),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => GetCredits()));
                        }),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                      onTap: () {
                        // Navigate to settings or perform desired action
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  // Navigate to settings or perform desired action
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(padding: EdgeInsets.all(20.0)),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.document_scanner_outlined,
                          size: 100,
                          color: Colors.indigo,
                        ),
                        Padding(padding: EdgeInsets.all(5.0)),
                        Text(
                          "You need to upload your",
                          style: TextStyle(fontSize: 15.0),
                        ),
                        Text(
                          "Doctor/Lab Report",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0),
                        ),
                      ],
                    )),
                    Icon(Icons.arrow_downward_rounded)
                  ],
                )),

            Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.all(20.0),
                  padding: const EdgeInsets.all(10.0),
                  width: double.infinity,
                  child: Card(
                    elevation: 6,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Column(
                      children: [
                        Expanded(
                            child: Container(
                          margin: EdgeInsets.only(
                              left: 20.0, right: 20.0, top: 20.0, bottom: 10.0),
                          child: MaterialButton(
                            elevation: 6,
                            minWidth: double.infinity,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                            color: Colors.indigo,
                            onPressed: () {
                              getImage(ImageSource.camera);
                            },
                            child: Text(
                              "Use Camera",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )),
                        const Text("or"),
                        Expanded(
                            child: Container(
                          margin: const EdgeInsets.only(
                              left: 20.0, right: 20.0, top: 10.0, bottom: 20.0),
                          child: MaterialButton(
                            elevation: 6,
                            minWidth: double.infinity,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                            color: Colors.indigo,
                            onPressed: () {
                              getImage(ImageSource.gallery);
                            },
                            child: Text(
                              "from Gallery",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ))
            // Container(
            //   margin: EdgeInsets.all(10.0),
            //   decoration: BoxDecoration(
            //     border: Border.all(color: Colors.grey), // Border color
            //     borderRadius: BorderRadius.circular(50.0), // Border radius
            //   ),
            //   child: TextField(
            //     controller: userInputController,
            //     decoration: InputDecoration(
            //       hintText: "Ask Virtual Doctor",
            //       suffixIcon: IconButton(
            //         icon: Icon(Icons.send),
            //         onPressed: () {},
            //       ),
            //       border: InputBorder.none, // Remove TextField's default border
            //       contentPadding:
            //           EdgeInsets.all(20.0), // Adjust content padding
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
