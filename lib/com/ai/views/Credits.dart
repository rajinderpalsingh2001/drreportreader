import 'package:drreportreader/com/ai/views/GetCredits.dart';
import 'package:flutter/material.dart';
import 'package:drreportreader/com/ai/service/globals.dart' as globals;

class Credits extends StatefulWidget {
  // int credit;
  Credits();

  @override
  State<Credits> createState() => _CreditsState();
}

class _CreditsState extends State<Credits> {
  // int credit;
  // _CreditsState(this.credit);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 0,

        // backgroundColor: Colors.purple.shade300,
        title: Text("My Credits"),
      ),
      body: Column(
        children: [
          ClipPath(
            clipper: CircularClipper(),
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
                  Text(
                    globals.credits.toString(),
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
              // 1 credit = 1 report analysis + 10 chats messages (5 assistant message + 5 your message)
              // 1 credit = more than 10 chat messages
              ListTile(
                leading: Column(
                  children: [
                    Icon(
                      Icons.mode_standby_rounded,
                      color: Colors.red,
                    ),
                    Text(
                      "1",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.0),
                    )
                  ],
                ),
                title: Text("1 Report Analysis + 10 Chat Messages"),
                subtitle: Text("5 Assistant Messages, 5 your Messages"),
              ),

              ListTile(
                leading: Column(
                  children: [
                    Icon(
                      Icons.mode_standby_rounded,
                      color: Colors.red,
                    ),
                    Text(
                      "1",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.0),
                    )
                  ],
                ),
                title: Text("20 Chat Messages"),
                subtitle: Text("after 10 Chat Messages"),
              )
            ],
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MaterialButton(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              shape: StadiumBorder(),
              minWidth: double.infinity,
              color: Colors.indigo,
              onPressed: () async {
                await Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => GetCredits()));
                setState(() {
                  globals.credits;
                });
              },
              child: Text(
                "Get more Credits",
                style: TextStyle(
                    color: Colors.indigo.shade50,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircularClipper extends CustomClipper<Path> {
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
