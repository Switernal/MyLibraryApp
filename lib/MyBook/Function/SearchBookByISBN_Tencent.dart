import 'package:flutter/material.dart';
import 'package:my_library/Functions/Network/Network.dart';
import 'package:my_library/MyBook/Controller/Book/MyBookDetailPage.dart';

// Controllers
import 'package:my_library/MyBook/Controller/Book/MyBookEditLentOutPage.dart';

// Packages
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Models
import 'package:my_library/MyBook/Model/MyBookModel.dart';

// Functions
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/Functions/Utils/LocalStorageUtils.dart';
import 'package:my_library/Shop/Controller/Book/PublishBookPage.dart';
import 'package:my_library/Shop/Model/ShopBookModel.dart';


/// ISBN查询接口(腾讯云)
class SearchBookByISBN_Tencent {

  /// 接口地址
  static String url = "";
  /// 路由
  static String route = "/book/getBookData";
  /// 缓存对象,每次创造新对象时调用工厂构造函数,不产生新对象
  static SearchBookByISBN_Tencent _defaultObject;


  /// 私有命名构造函数
  SearchBookByISBN_Tencent._privateConstructor() {}
  /// 工厂构造方法
  factory SearchBookByISBN_Tencent() {

    url = Network().getServerURL();
    //route = Network().getSearchBookRoute();

    if (_defaultObject == null) {
      _defaultObject = SearchBookByISBN_Tencent._privateConstructor();
    }
    return SearchBookByISBN_Tencent._defaultObject;
  }


  /// 发送请求
  Future<Map<String, dynamic>> sendRequest(String ISBN, BuildContext context) async {

    Utils.showToast("正在查找图书...", context, mode: ToastMode.Loading, duration: 10);
    // get参数
    Map<String, dynamic> paras = {
      "isbn" : ISBN,
    };
    // get请求
    var response = await Dio().get(url + route, queryParameters: paras);
    // 解析json
    var jsonData = response.data;
    // 返回json
    return jsonData;
  }


  /// 转Shopbook(腾讯api)
  Future<ShopBookModel> toShopBook(String ISBN, BuildContext context) async {
    var data = await sendRequest(ISBN, context);

    print(data);

    // ISBN不对
    if (data["status"] != 1) {
      print("查询图书有误");
      return null;
    }

    // 没有找到书
    if (data['obj']['showapi_res_body']['ret_code'] == -1) {
      return null;
    }

    var bookData = data['obj']['showapi_res_body']['data'];



    return ShopBookModel(
      coverURL: bookData['img'] ?? "https://i0.hdslb.com/bfs/album/5522dd1f5b742d1e1394a17f44d590646b63871d.gif",
      bookName: bookData['title'] ?? "",
      author: bookData['author'] ?? "",
      price_origin: double.tryParse(bookData['price']) ?? 0.0,
      press: bookData['publisher'] ?? "",
      publicationDate: bookData['pubdate'] ?? "",
      ISBN: bookData['isbn'] ?? "",
      introduction: bookData['gist'] ?? "暂无简介",
    );
  }


  /// 转MyBook(腾讯api)
  Future<MyBookModel> toMyBook(String ISBN, BuildContext context) async {
    var data = await sendRequest(ISBN, context);

    // ISBN不对
    if (data["status"] == 0) {
      print("error != null");
      return null;
    }

    // 没有找到书
    if (data['obj']['showapi_res_body']['ret_code'] == -1) {
      return null;
    }

    var bookData = data['obj']['showapi_res_body']['data'];

    // 获取默认书柜
    String defaultShelfName = await LocalStorageUtils.getDefaultShelf();

    return MyBookModel(
      coverURL: bookData['img'] ?? "https://i0.hdslb.com/bfs/album/5522dd1f5b742d1e1394a17f44d590646b63871d.gif",
      bookName: bookData['title'] ?? "",
      ISBN: bookData['isbn'] ?? "",

      price: bookData['publisher'] ?? "",
      notes: (bookData['binding'] ?? "") + (bookData['format'] ?? ""),

      author: bookData['author'] ?? "",
      translator: "",
      //translator: data["book_info"] == null || data["book_info"]["译者"] == null ? "" : data["book_info"]["译者"],
      press: bookData['publisher'] ?? "",
      publicationDate: bookData['pubdate'] ?? "暂无出版日期",

      totalPages: int.tryParse(bookData['page']) ?? 0,
      readProgress: 0,

      contentIntroduction: bookData['gist'] ?? "暂无简介",
      authorIntroduction: "暂无简介",

      bookShelf: defaultShelfName,
    );
  }




}