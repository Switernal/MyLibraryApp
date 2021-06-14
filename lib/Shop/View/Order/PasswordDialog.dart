import 'package:flutter/material.dart';

/// 描述：设置密码弹框功能
///
class MineDestorySetPwdPage extends StatefulWidget {
  @override
  _MineDestorySetPwdPageState createState() => _MineDestorySetPwdPageState();
}

class _MineDestorySetPwdPageState extends State<MineDestorySetPwdPage> {

  String pwdData = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool showError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, //把scaffold的背景色改成透明
      body: Container(
        color: Colors.white,
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: MediaQuery
            .of(context)
            .size
            .height,
        alignment: Alignment.bottomLeft,
        child: Column(
          children: <Widget>[

            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: 150,
            ),
            Container(
              height: 180,
              width: 300,
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      alignment: Alignment.topRight,
                      child: Icon(Icons.close),
                      width: 10,
                      height: 10,
                      padding: EdgeInsets.only(right: 5, top: 5),
                    ),

                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    behavior: HitTestBehavior.opaque,
                  ),
                  Container(
                    child: Text('请输入账户密码', style: TextStyle(fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),),
                  ),
                  Container(
                    height: 50,
                    width: 250,
                    margin: EdgeInsets.only(top: 30),
                    child: TextField(), //CustomJPasswordField(pwdData),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        showError ? Text('您输入的密码有误',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight
                              .w500),) : Container(),
                      ],
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
            // Align(
            //   child: Container(
            //     height: 200,
            //     width: MediaQuery.of(context).size.width,
            //     color: Colors.white,
            //     alignment: Alignment.bottomCenter,
            //     child: MyKeyboard(_onKeyDown),
            //   ),
            //   alignment: Alignment.bottomCenter,
            // )
          ],
        ),
      ),
    );
  }
}