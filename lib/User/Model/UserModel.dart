import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:my_library/main.dart' as Main;

import 'package:flutter/foundation.dart';
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/Functions/Utils/LocalStorageUtils.dart';
import 'package:my_library/User/Function/UserRequest.dart';

// 抽象用户
/*
abstract class AbstractUser {
  String userID;
  String userName;
  String phone;
}

 */

class UserModel {
  String userName;
  String password;
  String email;
  String phone;
  int userID;

  UserModel({this.userName = "", this.email = "", this.phone = "", this.password = "", this.userID = 0});

  // 判断系统中用户登录状态
  static Future<bool> getUserLoginStatus() {
    return LocalStorageUtils.isLogin();
  }

  // 设置系统用户登录状态
  static Future<bool> setUserLoginStatus(UserModel user) async {

    return await LocalStorageUtils.userLogin(
        userName: user.userName, 
        userEmail: user.email, 
        userPhone: user.phone, 
        userPasswd: user.password, 
        userID: user.userID
    );
  }

  // 设置系统用户登出
  static Future<bool> setUserLogoutStatus() async {
    return await LocalStorageUtils.userLogout();
  }

  // 获取系统中用户信息
  static Future<UserModel> getUserInfo_Local() async {
    var username;
    var email;
    var phone;
    var password;
    var userID;

    await LocalStorageUtils.getUserName_Local().then((value) => username = value);
    await LocalStorageUtils.getUserEmail_Local().then((value) => email = value);
    await LocalStorageUtils.getUserPhone_Local().then((value) => phone = value);
    await LocalStorageUtils.getUserID_Local().then((value) => userID = value);

    UserModel systemUser = UserModel(userName: username, email: email, phone: phone, userID: userID);

    return systemUser;
  }

  // 判断用户密码是否正确
  static Future<bool> isUserPasswordCorrect() {

  }

  // user转换成json
  Map<String, dynamic> toJson() => {
    "username" : this.userName,
    "password" : this.password,
    "email" : this.email,
    "phone" : this.phone,
    "user_id" : this.userID,
  };

  // 用户登录方法
  static Future<int> userLogin(String phone, String password) async {
    var request = UserRequest();
    await request.init();

    var result = -1;
    var jsonData = await request.Login(phone, password);
    result = jsonData["status"];

    if (result == 1) {
      print(jsonData["obj"]);
      await setUserLoginStatus(UserModel.fromJson(jsonData["obj"]));
      // 用户登录后需要对所有的Request重新进行初始化
      print("用户已登录");
      await Main.App_Initializator();
    }

    // 返回状态码
    return result;
  }

  // json转User方法
  UserModel.fromJson(Map<String, dynamic> jsonData) {
    userName = jsonData["username"];
    password = jsonData["password"];
    email = jsonData["email"];
    phone = jsonData["phone"];
    userID = jsonData["user_id"];
  }
}

// 专供商店使用的用户类
/*
class UserForShop implements AbstractUser {
  String userName;
  String phone;

  UserForShop({this.userName, this.phone});
}

 */