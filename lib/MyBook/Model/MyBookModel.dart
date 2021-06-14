
import 'package:flutter/material.dart';

class MyBookModel {
  String coverURL;    // 封面URL

  String bookName;    // 书名
  String ISBN;        // ISBN号

  int shelfID;        // 书柜ID
  String bookShelf;   // 书柜
  String notes;       // 备注
  String lender;      // 借出人
  bool isLentOut;     // 是否借出

  String buyFrom;     // 购买渠道
  String buyDate;     // 购买日期
  double price;       // 价格

  String author;      // 作者
  String translator;  // 译者
  String press;       // 出版社
  String publicationDate; // 出版时间
  int totalPages;     // 总页数
  int readProgress; // 阅读进度

  String contentIntroduction; // 内容简介
  String authorIntroduction;  // 作者简介

  /// 构造函数
  MyBookModel ({
    //this.coverURL = "https://img3.doubanio.com/f/shire/5522dd1f5b742d1e1394a17f44d590646b63871d/pics/book-default-lpic.gif",
    this.coverURL = "https://www.hualigs.cn/image/60bcfe294addc.jpg",

    this.bookName = "",
    this.ISBN = "",

    this.shelfID = 0,
    this.bookShelf = "",
    this.notes = "",
    this.lender = "",
    this.isLentOut = false,

    this.buyFrom = "",
    this.buyDate = "",
    this.price = 0.0,

    this.author = "",
    this.translator = "",
    this.press = "",
    this.publicationDate = "",
    this.totalPages = 0,
    this.readProgress = 0,

    this.contentIntroduction = "",
    this.authorIntroduction = "",
  }) {
    /*
    print("coverURl: " + coverURL + "\n" +
        "bookName: " + bookName + "\n" +
        "ISBN: " + ISBN + "\n" +
        "notes: " + notes + "\n" +
        "price: " + price.toString() + "\n" +
        "author: " + author + "\n" +
        "translator: " + translator + "\n" +
        "press: " + press + "\n" +
        "publicationDate: " + publicationDate + "\n" +
        "totalPages: " + totalPages.toString() + "\n" +
        "content_intro: " + coverURL + "\n" +
        "author_intro: " + coverURL + "\n");
     */
  }

  // 转换Json
  Map<String, dynamic> toJson_Local() => <String, dynamic>{
    'coverURL' : coverURL,

    'bookName' : bookName,
    "ISBN" : ISBN,

    "shelf_id" : shelfID,
    "bookShelf" : bookShelf,
    "notes" : notes,
    "lender" : lender,
    "isLentOut" : isLentOut,

    "buyFrom" : buyFrom,
    "buyDate" : buyDate,
    "price" : price.toString(),

    "author" : author,
    "translator" : translator,
    "press" : press,
    "publicationDate" : publicationDate,
    "totalPages" : totalPages.toString(),
    "readProgress" : readProgress.toString(),

    "content_intro" : contentIntroduction,
    "author_intro" : authorIntroduction,
  };


  // toJson 网络方法
  Map<String, dynamic> toJson() => <String, dynamic>{
    'coverUrl' : coverURL,

    "bookName" : bookName,
    "isbn" : ISBN,

    "shelf_id" : shelfID == 0 ? null : shelfID,
    "shelfName" : bookShelf,
    "notes" : notes,
    "lender" : lender,
    "lentOut" : isLentOut,

    "buyFrom" : buyFrom,
    "buyDate" : (buyDate == "" || buyDate == null) ? null : buyDate,
    "price" : price.toString(),

    "author" : author,
    "translator" : translator,
    "press" : press,
    "publicationDate" : publicationDate == "" ? null : publicationDate,
    "totalPages" : totalPages,
    "readProgress" : readProgress,

    "contentIntroduction" : contentIntroduction,
    "authorIntroduction" : authorIntroduction,
  };

  // Json转对象
  MyBookModel.fromJson_Local(Map<String, dynamic> jsonData) :
        coverURL = jsonData['coverURL'],

        bookName = jsonData['bookName'],
        ISBN = jsonData["ISBN"],

        bookShelf = jsonData["bookShelf"],
        notes = jsonData["notes"],
        lender = jsonData["lender"],
        isLentOut = jsonData["isLentOut"],

        buyFrom = jsonData["buyFrom"],
        buyDate = jsonData["buyDate"] == null ? "" : jsonData["buyDate"],
        price = double.parse(jsonData["price"]),

        author = jsonData["author"],
        translator = jsonData["translator"],
        press = jsonData["press"],
        publicationDate = jsonData["publicationDate"],
        totalPages = int.parse(jsonData["totalPages"]),
        readProgress = int.parse(jsonData["readProgress"]),

        contentIntroduction = jsonData["content_intro"],
        authorIntroduction = jsonData["author_intro"]
  ;

  // json转对象, 网络
  MyBookModel.fromJson_Network(Map<String, dynamic> jsonData) :
        coverURL = jsonData['coverUrl'],

        bookName = jsonData['bookName'],
        ISBN = jsonData["isbn"],

        //bookShelf = json["bookShelf"],
        shelfID = jsonData["shelf_id"],
        bookShelf = jsonData["shelfName"],
        notes = jsonData["notes"],
        lender = jsonData["lender"],
        isLentOut = jsonData["lentOut"],

        buyFrom = jsonData["buyFrom"],
        buyDate = jsonData["buyDate"] == null ? "" : jsonData["buyDate"],
        price = double.parse(jsonData["price"].toString()),

        author = jsonData["author"],
        translator = jsonData["translator"],
        press = jsonData["press"],
        publicationDate = jsonData["publicationDate"],
        totalPages = jsonData["totalPages"],
        readProgress = jsonData["readProgress"],

        contentIntroduction = jsonData["contentIntroduction"],
        authorIntroduction = jsonData["authorIntroduction"];


  @override
  String toString() {
    // TODO: implement toString
    return
      "coverURL: " + coverURL + "\n" +
      "bookName: " + bookName + "\n" +
      "ISBN: " + ISBN + "\n" +
      "notes: " + notes + "\n" +
      "price: " + price.toString() + "\n" +
      "author: " + author + "\n" +
      "translator: " + translator + "\n" +
      "press: " + press + "\n" +
      "publicationDate: " + publicationDate + "\n" +
      "totalPages: " + totalPages.toString() + "\n" +
      "content_intro: " + contentIntroduction + "\n" +
      "author_intro: " + authorIntroduction + "\n";
  }

  /*
  Map<String, String> toMap() {
    Map<String, String> bookMap;
    bookMap["coverURL"] = coverURL;
    bookMap["bookName"] = bookName;
    
    bookMap["shelf_name"] = shelfID.toString();

    bookMap["notes"],
    json["lender"],
    json["lentOut"],

    json["buyFrom"],
    json["buyDate"],
    double.parse(json["price"].toString()),

    json["author"],
    json["translator"],
    json["press"],
    json["publicationDate"],
    json["totalPages"],
    json["readProgress"],

    json["contentIntroduction"],
    json["authorIntroduction"]
  }

   */

}