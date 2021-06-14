import 'package:flutter/material.dart';
import 'package:my_library/Functions/Utils/LocalStorageUtils.dart';
import 'package:my_library/Home/Controller/MyLibrary.dart';
import 'package:my_library/User/Controller/UserLoginPage.dart';

// 入口页面

class EnterPage extends StatefulWidget {

  bool isLogin = false;

  /// 由main方法处传入 isLogin, 因为需要异步, 不能在这里获取
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

  /// 传入setState, 这样退出登录的时候刷新的是入口页, 可以切换入口页
  /// 使用 widget.isLogin 来触发setState
  /// 因为商店里购买商品支付成功后返回的是路由栈中的第一页, 也就是首页, 如果采用LoginPage push到首页, 会出问题
  /// 所以登陆成功后先返回这个入口页, 然后刷新入口页, 切换到首页, 保证首页是路由栈中的第一页
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