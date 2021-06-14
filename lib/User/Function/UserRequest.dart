import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_library/Functions/Network/Network.dart';
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/User/Model/UserModel.dart';

import '../../Functions/Utils/LocalStorageUtils.dart';

// 网络请求功能封装类



class UserRequest {

  /// 服务器的主机
  static String url = "";

  /// 获取当前UserID
  // int userID = 0;

  /// 用户路由
  Map<dynamic, dynamic> allUserRoutes = {};

  /// 缓存对象
  static UserRequest _defaultObject = UserRequest._privateConstructor();

  UserRequest._privateConstructor() {
    // 仅用于构造
  }

  /// 工厂构造方法
  factory UserRequest() {
    url = Network().getServerURL();
    return UserRequest._defaultObject;
  }

  /// 初始化器
  Future<bool> init() async {
    url = Network().getServerURL();
    allUserRoutes =  Network().getUserRoutes();
    /*
    await LocalStorageUtils.getUserID_Local().then((value) {
      // 用户可能没登录, 这时获取id会得到null,得判断一下
      if (value != null) {
        userID = value;
      }
    });
     */
    return true;
  }

  /// 用户注册
  Future<int> Register(Map userInfo) async {
    // 1.获取路由
    var route = allUserRoutes["register"];

    // 2.参数
    Map<String, dynamic> paras = {
      "username" : userInfo["username"],
      "password" : userInfo["password"],
      "email" : userInfo["email"],
      "phone" : userInfo["phone"]
    };

    // 3.发送请求
    final response = await Dio().get(url + route, queryParameters: paras);

    // 4.解析response
    var result = response.data;

    // 5. 返回
    return result["status"];
  }

  /// 用户登录
  Future<dynamic> Login(String phone, String password) async {

    print("login");

    // 1.获取路由
    var route = allUserRoutes["login"];
    // 2.参数
    Map<String, dynamic> paras = {
      "phone" : phone,
      "password" : password,
    };
    // 3.发送请求
    final response = await Dio().get(url + route, queryParameters: paras);
    // 4.解析response
    var result = response.data;

    // 4. 返回
    return result;
  }

  /// 用户信息更新
  /// 参数 [userInfo] 用户详细资料的json
  /// status:
  // 	   1 --修改成功
  //     0 --没有该条信息
  //     -1 --该手机号已注册（当手机号有修改时）
  //     -2 --该email已注册（当email有修改时）

  Future<int> Update(Map<String, dynamic> userInfo) async {
    // 1.获取路由
    var route = allUserRoutes["update"];

    // 获取用户ID
    int userID = await LocalStorageUtils.getUserID_Local();

    // 2.参数
    Map<String, dynamic> paras = {
      "username" : userInfo["username"],
      "password" : userInfo["password"],
      "email" : userInfo["email"],
      "phone" : userInfo["phone"],
      "user_id" : userID
    };

    // 3.发送请求
    final response = await Dio().get(url + route, queryParameters: paras);
    // 4.解析response
    var result = response.data;
    // 5. 返回
    return result["status"];
  }

  /// 通过 user_id 查询用户信息
  Future<UserModel> getUserByID(int userID) async {
    // 1.获取路由
    var route = allUserRoutes["getUserByID"];
    // 2.参数
    Map<String, dynamic> paras = {
      "user_id" : userID
    };

    // 3.发送请求
    final response = await Dio().get(url + route, queryParameters: paras);

    // 4.解析response
    var result = response.data;


    // 5.返回json转对象
    return UserModel.fromJson(result["obj"]);
  }


}






/*
// TODO: 上传图片
  // 参数：（图片路径，学号）
  // 返回值：response
  Future<Response> uploadImage(String imagePath, String stu_number, BuildContext context) async {
    // 1.拼接URL
    final url = "http://${WebURL}:8000/photo";

    print(imagePath);

    // 2.准备上传数据
    FormData formData = FormData.fromMap({
      "stu_num": stu_number,
      "img": await MultipartFile.fromFile(imagePath,filename: "${stu_number}.jpg"),
    });

    // 3. 发送Post请求
    var dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
        onError: (DioError error) {
          print("拦截了错误");
          return error;
        }
    ));


    // 尝试请求
    try {
      var response = await dio.post(url, data: formData);
      print(response);
      // 4. 返回请求结果
      return response;

    } on DioError catch (e) {
      //设置错误对话框
      AlertDialog errorAlert = AlertDialog(
        title: Text("识别失败"),
        content: Text("上传的答题卡不合格, 请重新拍照"),
        actions: [
          FlatButton(
            child: Text("确定"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );

      //显示错误对话框
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return errorAlert;
        },
      );
    }

  }
*/