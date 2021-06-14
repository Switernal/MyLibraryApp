import 'package:flutter/material.dart';
import 'package:my_library/MyBook/Controller/Book/BookInfoFormPage.dart';
import 'package:my_library/MyBook/Controller/Book/MyBookDetailPage.dart';

// Controllers
import 'package:my_library/MyBook/Controller/Book/MyBookEditLentOutPage.dart';

// Packages
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_library/MyBook/Function/SearchBookByISBN_Tencent.dart';

// Models
import 'package:my_library/MyBook/Model/MyBookModel.dart';

// Functions
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/Functions/Utils/LocalStorageUtils.dart';
import 'package:my_library/Shop/Model/ShopBookModel.dart';


/// ISBN查询接口(竹简)
class SearchBookByISBN_Bamboo {
  static String api = "http://api.feelyou.top/isbn/";
  static String key = "?apikey=YourKey";

  /// 发送请求
  static Future<dynamic> sendRequest(String ISBN, BuildContext context) async {
    String url = api + ISBN + key;

    Utils.showToast("正在查找图书...", context, mode: ToastMode.Loading);

    print(url);

    var response = await Dio().get(url);
    var jsonData = Utils.textToJson(response.toString());

    return jsonData;
  }

  /// 转Mybook(竹简api)
  static Future<MyBookModel> toMyBook(String ISBN, BuildContext context) async {
    var data = await sendRequest(ISBN, context);

    // 如果返回结果error字段不为空, 则代表没有这本书(也可能是ISBN码错误)
    if (data["error"] != null) {
      print("error != null");
      return null;
    }

    // 获取默认书柜
    String defaultShelfName = await LocalStorageUtils.getDefaultShelf();

    return MyBookModel(
        coverURL: data["cover_url"] ?? "",
        bookName: data["title"] ?? "",
        ISBN: ISBN,

        price: (data["book_info"] == null || data["book_info"]["定价"] == null) ? 0.0 : Utils.getDoubleFromString(data["book_info"]["定价"]),//double.tryParse(data["book_info"]["定价"].toString().split('元')[0]),
        notes: data["book_info"] == null || data["book_info"]["装帧"] == null ? "" : data["book_info"]["装帧"],

        author: data["book_info"] == null || data["book_info"]["作者"] == null ? "" : data["book_info"]["作者"],
        translator: data["book_info"] == null || data["book_info"]["译者"] == null ? "" : data["book_info"]["译者"],
        press: data["book_info"] == null || data["book_info"]["出版社"] == null ? "" : data["book_info"]["出版社"],
        publicationDate: data["book_info"] == null || data["book_info"]["出版年"] == null ? "" : data["book_info"]["出版年"],

        totalPages: data["book_info"] == null || data["book_info"]["页数"] == null ? 0 : int.tryParse(data["book_info"]["页数"]),
        readProgress: 0,

        contentIntroduction: data["book_intro"] ?? "暂无内容简介",
        authorIntroduction: data["author_intro"] ?? "暂无作者简介",

        bookShelf: defaultShelfName,
    );
  }

  /// 转Mybook(竹简api)
  static Future<ShopBookModel> toShopBook(String ISBN, BuildContext context) async {
    var data = await SearchBookByISBN_Bamboo.sendRequest(ISBN, context);

    // 如果返回结果error字段不为空, 则代表没有这本书(也可能是ISBN码错误)
    if (data["error"] != null) {
      print("没找到图书");
      return null;
    }

    // print(data["book_info"]);

    // 获取默认书柜
    String defaultShelfName = await LocalStorageUtils.getDefaultShelf();

    return ShopBookModel(
      coverURL: data["cover_url"] ?? "https://www.hualigs.cn/image/60bcfe294addc.jpg",
      bookName: data["title"] ?? "",
      author: data["book_info"] == null || data["book_info"]["作者"] == null ? "" : data["book_info"]["作者"],
      price_origin: (data["book_info"] == null || data["book_info"]["定价"] == null) ? 0.0 : Utils.getDoubleFromString(data["book_info"]["定价"]),//double.tryParse(data["book_info"]["定价"].toString().split('元')[0]),
      press: data["book_info"] == null || data["book_info"]["出版社"] == null ? "" : data["book_info"]["出版社"],
      publicationDate: data["book_info"] == null || data["book_info"]["出版年"] == null ? "" : data["book_info"]["出版年"],
      ISBN: ISBN,
      introduction: data["book_intro"] ?? (data["book_intro"] == "" ? "暂无内容简介" : data["book_intro"]),
    );
    
  }





}