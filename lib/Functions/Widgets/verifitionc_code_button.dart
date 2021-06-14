import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_library/User/Controller/UserSignUpPage.dart';

///验证码按钮
class VerifitionCodeButton extends StatefulWidget {
  VerifitionCodeButton({Key key, this.onPressed, this.seconds, this.title, this.isPhoneNumberValid})
      : super(key: key);

  final void Function() onPressed;
  final int seconds;
  final String title;
  bool isPhoneNumberValid;

  @override
  _VerifitionCodeButtonState createState() => _VerifitionCodeButtonState();
}

class _VerifitionCodeButtonState extends State<VerifitionCodeButton> {
  Timer timer;
  var text;
  var seconds;

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    text = widget.title;
    seconds = widget.seconds;
  }

  @override
  Widget build(BuildContext context) {

    return FlatButton(

        disabledTextColor: Colors.grey,
        onPressed: () {
          if (timer == null) {
            if (widget.onPressed != null) widget.onPressed();
            if (!isPhoneNumberValid) return null;

            timer = Timer.periodic(Duration(seconds: 1), (_) {
              seconds--;
              if (seconds == 0) {
                text = widget.title;
                seconds = widget.seconds;
                timer.cancel();
                timer = null;
              } else {
                text = seconds.toString() + "s";
              }
              if (seconds == 57) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("一千零一夜"),
                        content: Text("您的验证码是: 3972"),
                        actions: <Widget>[

                          FlatButton(
                              child: Text("好"),
                              onPressed: () => Navigator.pop(context, "yes")),
                        ],
                      );
                    });
              }
              setState(() {});
            });
          }

          //Timer.periodic(Duration(seconds: 5), (timer) {});

        },
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .button
              .copyWith(color: Theme.of(context).primaryColor),
        ));
  }
}