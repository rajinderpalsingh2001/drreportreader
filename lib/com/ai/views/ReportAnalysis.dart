import 'dart:io';
import 'package:drreportreader/com/ai/service/api_service.dart';
import 'package:drreportreader/com/ai/service/firestore_service.dart';
import 'package:drreportreader/com/ai/views/ChatVirtualDoctor.dart';
import 'package:drreportreader/com/ai/views/Credits.dart';
import 'package:drreportreader/com/ai/widgets/credits_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:badges/badges.dart' as badges;
import 'package:drreportreader/com/ai/service/globals.dart' as globals;

class ReportAnalysis extends StatefulWidget {
  XFile imageFile;
  ReportAnalysis(this.imageFile);

  @override
  State<ReportAnalysis> createState() => _ReportAnalysisState(this.imageFile);
}

class _ReportAnalysisState extends State<ReportAnalysis> {
  XFile imageFile;
  _ReportAnalysisState(this.imageFile);

  List<Map<String, String>> messages = [];
  bool isAnalysingReport = true;
  String imageScannedText = "";
  String reportAnalysis = "";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scanAndAnalyse();
  }

  Future getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    var _script = TextRecognitionScript.latin;
    var _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    // final textDetector = GoogleMlKit.vision.textRecognizer();
    // RecognizedText recognisedText = await textDetector.processImage(inputImage);
    // await textDetector.close();

    _textRecognizer.close();

    imageScannedText = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        imageScannedText = imageScannedText + line.text + "\n";
      }
    }
  }

  scanAndAnalyse() async {
    setState(() {
      isAnalysingReport = true;
    });
    await getRecognisedText(imageFile);
    await analyseReport();
    // reportAnalysis =
    //     "I am debug analysis ok bro I am with you I am with you fine bro.";
    setState(() {
      isAnalysingReport = false;
    });
  }

  Future analyseReport() async {
    APIService obj = APIService();
    // messages.add({"role": "system", "content": imageScannedText});
    await obj.analyseReportText([
      {
        "role": "system",
        "content":
            "Please tell me what the doctor's report is saying provide me the analysis of it \" \n" +
                imageScannedText +
                "\""
      }
    ]).then((value) async {
      Map<String, dynamic> response = value;
      if (response["error"] == true) {
        messages.add({"role": "system", "content": response["message"]});
      } else {
        reportAnalysis = response["message"];
        messages.add({"role": "system", "content": response["message"]});
        await firestoreService
            .decrementCredits(_auth.currentUser!.uid)
            .then((value) {          
          setState(() {
            globals.credits = globals.credits - 1;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 0,
        // backgroundColor: Colors.purple.shade300,
        title: Text("Analysis"),
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
      floatingActionButton: isAnalysingReport
          ? Container()
          : FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ChatVirtualDoctor(messages)));
              },
              child: badges.Badge(
                badgeStyle: const badges.BadgeStyle(
                    badgeColor: Colors.orange,
                    elevation: 6,
                    padding: EdgeInsets.all(8.0)),
                position: badges.BadgePosition.custom(bottom: 20, start: 20),
                badgeContent: Text(
                  messages.length.toString(),
                  style: const TextStyle(color: Colors.black),
                ),
                child: const Icon(Icons.chat_bubble_outline),
              ),
            ),
      body: Column(
        children: [
          Container(
            height: 250,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40.0),
                  bottomRight: Radius.circular(40.0)),
              child: PhotoView(
                imageProvider: FileImage(File(imageFile.path)),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.indigo, // Set the background color
                ),
              ),
            ),
          ),
          isAnalysingReport
              ? Expanded(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text("We are analysing your Report"),
                    Text("Please Wait"),
                  ],
                ))
              : Expanded(
                  child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    // padding: EdgeInsets.only(top: 20.0),
                    margin: const EdgeInsets.all(20.0),
                    child: Text(
                      reportAnalysis,
                      textAlign: TextAlign.justify,
                    ),
                  ),
                )),
          Container(
            width: 500,
            padding: const EdgeInsets.only(
                left: 10.0, right: 25.0, top: 10.0, bottom: 10.0),
            margin: const EdgeInsets.only(right: 80.0),
            decoration: const BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(50.0),
                    bottomRight: Radius.circular(50.0))),
            alignment: Alignment.centerLeft,
            child: const Text(
              "These results are created by AI technology. It's important not to fully depend on these results and remember that we're not accountable for any incorrect diagnosis. These results are just an analysis of the report you provided. To get accurate advice, it's best to consult a doctor.",
              textAlign: TextAlign.justify,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 8.0),
            ),
          )
        ],
      ),
    );
  }
}
