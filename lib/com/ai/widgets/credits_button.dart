import 'package:drreportreader/com/ai/views/credits.dart';
import 'package:flutter/material.dart';
import 'package:drreportreader/com/ai/service/globals.dart' as globals;

class CreditsButton extends StatelessWidget {
  int credit;
  VoidCallback callBack;
  CreditsButton(this.credit, this.callBack);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: Colors.white70,
      onPressed: callBack,
      elevation: 6,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50.0),
              bottomLeft: Radius.circular(50.0))),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 5.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              credit.toString(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsets.all(2.0)),
            Icon(
              Icons.mode_standby_rounded,
              color: Colors.red,
            )
          ],
        ),
      ),
    );
  }
}
