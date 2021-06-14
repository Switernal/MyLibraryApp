
// Models
import 'package:flutter/material.dart';
import 'package:my_library/Functions/Utils/Utils.dart';

import '../../User/Model/UserModel.dart';

class ShopBookModel {
  int bookID; // 图书编号
  int userID;
  UserModel owner = UserModel(userName: "null", phone: "null");   // 持有者
  DateTime createTime = DateTime(2021, 5, 21, 10, 10, 0);  // 商品发布日期
  String coverURL;    // 封面图片 URL
  String bookName;    // 书名
  int appearance;  // 品相
  String author;      // 作者
  //String translator;  // 译者
  double price_origin;// 原价
  double price_now;   // 现价
  double expressPrice; // 运费
  String press;       // 出版社
  String publicationDate; // 出版时间
  String ISBN;        // ISBN号
  String introduction; // 内容简介
  bool isSoldOut;

  static List<String> appearanceList = ["全新", "品相优秀", "品相良好", "品相一般"];

  /// 构造函数
  ShopBookModel ({
    this.bookID = 0,
    this.userID = 0,
    this.owner,
    this.createTime,
    this.coverURL = "",
    this.bookName = "无",
    this.appearance = 2,
    this.author = "无",
    //this.translator = "",
    this.price_origin = 0.0,
    this.price_now = 0.0,
    this.expressPrice = 0.0,
    this.press = "无",
    this.publicationDate = "无",
    this.ISBN = "无",
    this.introduction = "暂无内容简介",
    this.isSoldOut = false
  });

  /// 转json
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "coverUrl" : this.coverURL,
      "author": this.author,
      "bookName": this.bookName,
      "conditions": this.appearance,
      "createDate": Utils.dateTimeToString(createTime),
      "iSBN": this.ISBN,
      "introduction": this.introduction,
      "origPrice": this.price_origin,
      "practicalPrice": this.price_now,
      "expressPrice" : this.expressPrice,
      "press": this.press,
      "publishDate": this.publicationDate,
      "user_id": this.userID
    };
  }


  /// Json 转 ShopBookModel
  ShopBookModel.fromJson_Network(Map<String, dynamic> jsonData) {
    this.coverURL = jsonData["coverUrl"] ?? "";
    this.author = jsonData["author"] ?? "";
    this.bookName = jsonData["bookName"] ?? "";
    this.appearance = jsonData["conditions"] ?? 0;
    this.createTime = DateTime.tryParse(jsonData["createDate"]) ?? DateTime.now();
    this.ISBN = jsonData["iSBN"] ?? "";
    this.introduction = jsonData["introduction"] ?? "";
    this.price_origin = double.tryParse(jsonData["origPrice"].toString()) ?? 0.0;
    this.price_now = double.tryParse(jsonData["practicalPrice"].toString()) ?? 0.0;
    this.expressPrice = double.tryParse(jsonData["expressPrice"].toString()) ?? 0.0;
    this.press = jsonData["press"] ?? "";
    this.publicationDate = jsonData["publishDate"] ?? "";
    this.userID = jsonData["user_id"] ?? 0;
    this.bookID = jsonData["good_id"] ?? 0;
    this.isSoldOut = jsonData["soldOut"] ?? false;
  }
}