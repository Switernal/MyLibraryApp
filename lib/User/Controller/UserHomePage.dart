import 'package:flutter/material.dart';

// Functions
import 'package:my_library/Functions/Utils/Utils.dart';

class UserHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return UserHomePageState();
  }
}

class UserHomePageState extends State<UserHomePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("个人空间"),),
      body: Column(
        children: [
          RaisedButton(onPressed: () => Utils.showToast("成功", context, mode: ToastMode.Success)),
          RaisedButton(onPressed: () => Utils.showToast("警告", context, mode: ToastMode.Warning)),
          RaisedButton(onPressed: () => Utils.showToast("错误", context, mode: ToastMode.Error)),
          RaisedButton(onPressed: () => Utils.showToast("加载中", context, mode: ToastMode.Loading)),
          RaisedButton(onPressed: () => Utils.showToast("消息", context, mode: ToastMode.Message)),
        ],
      ),
    );
  }
}