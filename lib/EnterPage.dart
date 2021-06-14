import 'package:flutter/material.dart';
import 'package:my_library/Functions/Utils/LocalStorageUtils.dart';
import 'package:my_library/Home/Controller/MyLibrary.dart';
import 'package:my_library/User/Controller/UserLoginPage.dart';

class EnterPage extends StatefulWidget {

  bool isLogin = false;

  EnterPage({this.isLogin});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return EnterPageState();
  }
}

class EnterPageState extends State<EnterPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    if (widget.isLogin) {
      return MyLibrary(logoutRefreshState: () {setState(() {widget.isLogin = false;});},);
    } else {
      return UserLoginPage(refreshEnterPage: () {setState(() {widget.isLogin = true;});},);
    }
  }

}

/*

Navigator.push(context,
          MaterialPageRoute(
              settings: RouteSettings(name: "Login"),
              builder: (context) => MyLibrary()));
 */