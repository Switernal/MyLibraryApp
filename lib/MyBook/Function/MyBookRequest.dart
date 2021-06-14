
import 'package:flutter/material.dart';
import 'dart:convert';

/// Packages
import 'package:dio/dio.dart';

/// Fucntions
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/MyBook/Model/BookShelfModel.dart';
import '../../Functions/Network/Network.dart';
import 'package:my_library/Functions/Utils/LocalStorageUtils.dart';

/// Models
import 'package:my_library/MyBook/Model/MyBookModel.dart';

/// 本地图书管理-接口
class MyBookRequest {
  
  /// 接口地址
  static String url = "";

  /// UserID
  int UserID = 0;

  /// 所有路由
  Map allMyBookRoutes = {};

  /// 缓存对象,每次创造新对象时调用工厂构造函数,不产生新对象
  static MyBookRequest _defaultObject;


  /// 私有命名构造函数

  MyBookRequest._privateConstructor() {
    // print("MyBookRequest._privateConstructor");
  }


  /// 工厂构造方法
  factory MyBookRequest() {

    url = Network().getServerURL();

    if (_defaultObject == null) {
      _defaultObject = MyBookRequest._privateConstructor();
    }
    return MyBookRequest._defaultObject;
  }

  /// 获取mybook的所有路由
  Future<bool> init() async {
    url = Network().getServerURL();
    allMyBookRoutes = Network().getMyBookRoutes();
    UserID = await LocalStorageUtils.getUserID_Local();

    return true;
  }



  /// 一. 查询
  /// 1. 查询全部图书
  /// 无参数,返回值为图书对象列表
  Future<List<MyBookModel>> getAllBooks() async {
    // 获取查询全部图书路由
    var route = allMyBookRoutes["Query"]["getAllBooks"];
    // get参数
    Map<String, dynamic> paras = {
      "user_id" : UserID
    };
    // 发送请求
    var response = await Dio().get(url + route, queryParameters: paras);
    // 解析数据
    // 也可写成: Map jsonData = response.data;
    Map jsonData = json.decode(response.toString());

    //print(response.data);
    
    // 检查状态码
    switch (jsonData["status"]) {
      // 状态码为0: 没有图书,返回空
      case 0:
        return [];
        break;
      // 状态码为1: 返回图书结果
      case 1:
        List<MyBookModel> books = [];
        List booksData = jsonData["obj"];
        booksData.forEach((bookJson) {
          books.add(MyBookModel.fromJson_Network(bookJson));
        });
        return books;
        break;
      default:
        return [];
    }
  }

  /// 2. 根据ISBN查询单本图书
  /// 参数仅有一个: [ISBN] 为书号
  Future<MyBookModel> getBookByISBN({@required String ISBN}) async {
    // 路由路由
    var route = allMyBookRoutes["Query"]["searchBook"];
    // get参数
    Map<String, dynamic> paras = {
      "user_id" : UserID,
      "isbn" : ISBN,
    };
    // 发送请求
    var response = await Dio().get(url + route, queryParameters: paras);
    // 解析数据
    // 也可写成: Map jsonData = response.data;
    Map jsonData = json.decode(response.toString());

    // 检查状态码
    switch (jsonData["status"]) {
    // 状态码为0: 图书不存在
      case 0:
        return null;
        break;
    // 状态码为1: 返回图书结果
      case 1:
        return MyBookModel.fromJson_Network(jsonData["obj"]);
        break;
      default:
        return null;
    }
  }
  
  /// 3. 按书名查找图书【支持模糊查询，仅提供部分字】
  Future<List<MyBookModel>> getBooksByName({@required String bookName}) async {
    // 获取路由
    var route = allMyBookRoutes["Query"]["searchBookByName"];
    // get参数
    Map<String, dynamic> paras = {
      "user_id" : UserID,
      "bookName" : bookName,
    };
    // 发送请求
    var response = await Dio().get(url + route, queryParameters: paras);
    // 解析数据
    // 也可写成: Map jsonData = response.data;
    Map jsonData = json.decode(response.toString());

    // 检查状态码
    switch (jsonData["status"]) {
    // 状态码为0: 没有图书,返回空
      case 0:
        return [];
        break;
    // 状态码为1: 返回图书结果
      case 1:
        List<MyBookModel> books = [];
        List booksData = jsonData["obj"];
        booksData.forEach((bookJson) {
          books.add(MyBookModel.fromJson_Network(bookJson));
        });
        return books;
        break;
      default:
        return [];
    }
  }

  /// 4. 查询所有书柜
  Future<List<BookShelfModel>> getShelfs() async {

    // 获取路由
    var route = allMyBookRoutes["Query"]["getShelfs"];
    // get参数
    Map<String, dynamic> paras = {
      "user_id" : UserID,
    };

    // 发送请求
    var response = await Dio().get(url + route, queryParameters: paras);
    // 解析数据
    // 也可写成: Map jsonData = response.data;
    Map<String, dynamic> jsonData = json.decode(response.toString());

    // 检查状态码
    switch (jsonData["status"]) {
    // 状态码为0: 没有书架,返回空
      case 0:
        return [];
        break;
    // 状态码为1: 返回书架结果
      case 1:
        List<BookShelfModel> shelfs = [];
        List shelfData = jsonData["obj"];
        shelfData.forEach((shelfJson) {
          shelfs.add(BookShelfModel.fromJson_Network(shelfJson));
        });
        return shelfs;
        break;
      default:
        return [];
    }
  }

  /// 5. 查询单个书柜里所有图书
  Future<List<MyBookModel>> getBooksFromShelf({@required String shelfName}) async {
    // 获取路由
    var route = allMyBookRoutes["Query"]["getBookFromShelf"];
    // get参数
    Map<String, dynamic> paras = {
      "user_id" : UserID,
      "shelfName" : shelfName,
    };

    // 发送请求
    var response = await Dio().get(url + route, queryParameters: paras);

    // 解析数据
    // 也可写成: Map jsonData = response.data;
    Map jsonData = json.decode(response.toString());

    // 检查状态码
    switch (jsonData["status"]) {
    // 状态码为0: 没有图书,返回空
      case 0:
        return [];
        break;
    // 状态码为1: 返回图书结果
      case 1:
        List<MyBookModel> books = [];
        List booksData = jsonData["obj"];
        booksData.forEach((bookJson) {
          books.add(MyBookModel.fromJson_Network(bookJson));
        });
        return books;
        break;
      default:
        return [];
    }
  }

  /// 6. 查询每个书柜里图书数量
  /// 返回值类型: Map<[书柜名] : 数量>
  Future<Map<String, dynamic>> getBooksCountInShelf() async {
    // 获取路由
    var route = allMyBookRoutes["Query"]["getBookCountInShelf"];
    // get参数
    Map<String, dynamic> paras = {
      "user_id" : UserID,
    };
    // 发送请求
    var response = await Dio().get(url + route, queryParameters: paras);
    // 解析数据
    // 也可写成: Map jsonData = response.data;
    Map jsonData = json.decode(response.toString());

    // 检查状态码
    switch (jsonData["status"]) {
    // 状态码为0: 没有书架
      case 0:
        return {};
        break;
    // 状态码为1: 成功
      case 1:
        return jsonData["obj"];
        break;
      default:
        return {};
    }
  }

  /// 7. 查询出版社数量

  Future<dynamic> getPressCount() async {
    // 获取路由
    var route = allMyBookRoutes["Query"]["getPressCount"];
    // get参数
    Map<String, dynamic> paras = {
      "user_id" : UserID,
    };
    // 发送请求
    var response = await Dio().get(url + route, queryParameters: paras);
    // 解析数据
    // 也可写成: Map jsonData = response.data;
    Map jsonData = json.decode(response.toString());
    // 返回结果
    return jsonData["obj"];
  }

  /// 8. 查询作者数量
  Future<int> getAuthorCount() async {
    // 获取路由
    var route = allMyBookRoutes["Query"]["getAuthorCount"];
    // get参数
    Map<String, dynamic> paras = {
      "user_id" : UserID,
    };
    // 发送请求
    var response = await Dio().get(url + route, queryParameters: paras);
    // 解析数据
    // 也可写成: Map jsonData = response.data;
    Map jsonData = json.decode(response.toString());
    // 返回结果
    return jsonData["obj"];
  }

  /// 二.增加
  /// 1. 新增图书

  Future<int> addBook({@required MyBookModel newBook}) async {
    // print("allMyBookRoutes : " + allMyBookRoutes.toString());
    // 获取路由
    var route = allMyBookRoutes["Add"]["addBook"];
    // get参数
    Map<String, dynamic> jsonData = json.decode(json.encode(newBook));
    jsonData["user_id"] = UserID;

    // 发送请求
    var response = await Dio().post(url + route, data: jsonData);

    // 返回结果
    return response.data["status"];
  }

  /// 2. 新增书柜
  Future<int> addShelf({@required String newShelfName}) async {
    // 获取路由
    var route = allMyBookRoutes["Add"]["addShelf"];
    // get参数
    print("UserID = " + UserID.toString());
    Map jsonData = {
      "user_id" : UserID,
      "number" : 0,
      "shelfName" : newShelfName,
    };

    // Map<String, dynamic> jsonData = ;

    // 发送请求
    var response = await Dio().post(url + route, data: jsonData);

    // 返回结果(状态码)
    return response.data["status"];
  }

  /// 三.修改
  /// 1. 修改图书信息

  Future<int> updateBook({@required MyBookModel book}) async {
    // 获取路由
    var route = allMyBookRoutes["Update"]["updateBook"];
    // get参数
    Map<String, dynamic> jsonData = json.decode(json.encode(book));
    jsonData["user_id"] = UserID;

    // print(jsonData);
    // 发送请求
    var response = await Dio().post(url + route, data: jsonData);

    // 返回结果
    return response.data["status"];
  }

  /// 2. 修改书柜名
  Future<int> updateShelf({@required String oldShelfName, @required String newShelfName}) async {
    // 获取路由
    var route = allMyBookRoutes["Update"]["updataShelf"];
    // get参数
    Map<String, dynamic> jsonData = {
      "user_id" : UserID,
      "old_shelfName" : oldShelfName,
      "new_shelfName" : newShelfName,
    };
    // 发送请求
    var response = await Dio().get(url + route, queryParameters: jsonData);

    // 返回结果(状态码)
    return response.data["status"];
  }

  /// 四.删除
  /// 1. 删除图书
  Future<int> deleteBook({@required String ISBN}) async {
    // 获取路由
    var route = allMyBookRoutes["Delete"]["deleteBook"];
    // get参数
    Map<String, dynamic> jsonData = {
      "user_id" : UserID,
      "isbn" : ISBN,
    };
    print("deleteBook");
    // 发送请求
    var response = await Dio().post(url + route, data: jsonData);

    // print("delete book");

    // 返回状态码
    return response.data["status"];
  }

  /// 2. 删除书柜
  Future<int> deleteShelf({@required String shelfName}) async {
    // 获取路由
    var route = allMyBookRoutes["Delete"]["deleteShelf"];
    // get参数
    Map<String, dynamic> jsonData = {
      "user_id" : UserID,
      "shelfName" : shelfName,
    };
    // 发送请求
    var response = await Dio().get(url + route, queryParameters: jsonData);

    // 返回状态码
    return response.data["status"];
  }

}