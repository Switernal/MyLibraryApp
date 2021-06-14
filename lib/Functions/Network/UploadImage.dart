import 'dart:convert';
import 'dart:io';

// Functions
import 'package:flutter/cupertino.dart';

import 'Network.dart';
import 'package:my_library/Functions/Utils/ImageUtils.dart';
import 'package:my_library/Functions/Utils/LocalStorageUtils.dart';

// Packages
import 'package:dio/dio.dart';

class UploadImage {

  static String _api = "遇见图床Api";
  static String _token = "your token";
  static String _apiType = "bilibili";

  /// 上传方法
  /// 使用遇见图床的接口
  /// [imagePath]是原图文件位置,选择后会返回一个这个玩意,[ISBN]用来重命名用
  static Future<Map<String, dynamic>> upload({@required String imagePath, @required String ISBN}) async {

    // 获取用户ID
    int userID = await LocalStorageUtils.getUserID_Local();

    // 这里更新了imagePath, 是处理过的图片(压缩+重命名)
    imagePath = await ImageUtils.processImage(imagePath, ISBN, userID.toString());

    // 要上传的数据, FormData为Dio包中提供, Multipart
    FormData uploadData = FormData.fromMap({
      // 可填参数filename,对上传文件重命名,但这里传进来的图片已经重命名好了,无需再次重命名
      "image": await MultipartFile.fromFile(imagePath),
      "token": _token,
      "apiType" : _apiType,
    });
    var response = await Dio().post(_api, data: uploadData);
    Map<String, dynamic> jsonData = response.data;

    /// 提取signature, 可以日后更新图片
    String distributeUrl = jsonData["data"]["url"]["distribute"].toString();
    String signature = distributeUrl.substring(distributeUrl.lastIndexOf('/')+1);

    /// 结果是一个Map
    /// [code]代表状态码,[url]是图片url,[signature]是图片标识,更新图片用
    /// 状态码200表示成功,返回url,400为失败,返回Failed
    var result = {
      "code": jsonData["code"],
      "url" : jsonData["data"]["url"][_apiType],
      "signature" : signature
    };

    return result;
  }

}