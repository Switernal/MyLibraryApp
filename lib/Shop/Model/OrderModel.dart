
import 'package:flutter/material.dart';
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/Shop/Model/ShopBookModel.dart';
import 'package:my_library/User/Model/UserModel.dart';

enum OrderMode {
  buyer,
  seller,
}

class OrderModel {
  String orderID;          // 订单号
  int bookID;           // 商品编号
  int userID;           // 用户id
  DateTime createTime = DateTime.now();    // 订单创建时间
  double price;         // 价格
  String consigneeName;    // 收货人姓名
  String consigneePhone;   // 收货人手机
  String consigneeAddress; // 收货人地址
  String notes;           // 备注

  int orderStatus;       // 订单状态(未发货\已发货\完成)
  String expressNumber;  // 快递号
  ShopBookModel book;    // 订单包含的商品信息

  static List<String> orderStatusList = ["等待卖家发货", "等待买家收货", "交易成功"];
  // static List<String> orderStatusListHintTitle = ["等待卖家发货", "等待买家签收", "交易成功"];
  static List<String> buyerOrderStatusListHintContent = ["卖家发货后您可关注物流记录", "如果您在10天内仍未确认收货, 系统会自动确认, 钱款将会打入卖家账户中", "如果您遇到问题，您可以申请客服介入"];
  static List<String> sellerOrderstatusListHintContent = ["请您及时联系快递公司发货并填写发货单号", "如果买家在10天内仍未确认收货, 系统会自动确认, 钱款将会打入您的账户中", "如果您遇到问题，您可以申请客服介入"];
  OrderModel({
    @required this.orderID = "",
    @required this.bookID = 0,
    @required this.userID = 0,
    @required this.createTime,
    @required this.price = 0.0,
    @required this.consigneeName = "",
    @required this.consigneePhone = "",
    @required this.consigneeAddress = "",
    @required this.orderStatus = 0,
    this.notes = "",
    this.expressNumber = "",
    ShopBookModel book
  }) {
    if (book == null) {
      this.book = ShopBookModel();
    } else {
      this.book = book;
    }
  }

  // 转json
  Map<String, dynamic> toJson() {
    return <String, dynamic> {
      "orderID" : orderID,
      "good_id" : bookID,
      "user_id" : userID,
      "createDate" : Utils.dateTimeToString(createTime),
      "origPrice" : book.price_now,
      "practicalPrice" : price,
      "consignee" : consigneeName,
      "phone" : consigneePhone,
      "address" : consigneeAddress,
      "publisher_id" : book.userID,
      "notes" : notes,
      "state" : orderStatus,
    };
  }

  // 从Json转对象
  OrderModel.fromJson_Network(Map<String, dynamic> jsonData) {
    this.book = ShopBookModel();
    orderID = jsonData["orderID"] ?? "";
    bookID = jsonData["good_id"] ?? 0;
    userID = jsonData["user_id"] ?? 0;
    createTime = DateTime.tryParse(jsonData["createDate"]) ?? DateTime.now();
    // price = double.tryParse(jsonData["origPrice"].toString()) ?? 0.0;
    price = double.parse(jsonData["practicalPrice"].toString()) ?? 0.0;
    consigneeName = jsonData["consignee"] ?? "";
    consigneePhone = jsonData["phone"] ?? "";
    consigneeAddress = jsonData["address"] ?? "";
    book.userID = jsonData["publisher_id"] ?? 0; // 可能会出问题
    notes = jsonData["notes"] ?? "";
    expressNumber = jsonData["expressNumber"] ?? "";
    orderStatus = jsonData["state"] ?? 0;
  }
}