import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_library/EnterPage.dart';
import 'package:my_library/Functions/Network/Network.dart';


import 'Home/Controller/MyLibrary.dart';
import 'Functions/Utils/Utils.dart';
import 'package:permission_handler/permission_handler.dart';

// Packages
import 'package:url_launcher/url_launcher.dart';

// Models
import 'MyBook/Model/MyBookModel.dart';

// Functions
import 'package:my_library/Functions/Utils/LocalStorageUtils.dart';

// Requests
import 'package:my_library/User/Function/UserRequest.dart';
import 'MyBook/Function/MyBookRequest.dart';
import 'package:my_library/Shop/Function/ShopRequest.dart';


TabController _mainTabController;
List mainTabs = ["在柜书籍", "借出书籍"];

// Shared_Preferences初始化器
Future<void> Shared_Preferences_Initialize() async {
  await LocalStorageUtils.initLocalStorage().then((value) => value ? print("Shared_preferences 初始化成功") : print("Shared_Preferences 初始化失败"));
  await LocalStorageUtils.getInitializationString();
}

/// 程序初始化器
Future<void> App_Initializator() async {

  print("当前时间戳: " + (DateTime.now().millisecondsSinceEpoch).toString());

  /// 1. 初始化Shared_Preferences
  await Shared_Preferences_Initialize();

  /// 2. 所有request的初始化都在这里进行, 这样进入App可以直接用
  /// (1) Network 初始化
  Network net = Network();
  bool isNetworkInitSucceed = await net.init();
  print("Network初始化: $isNetworkInitSucceed");
  print("Network的servers: ${net.servers}");

  /// (2) UserModel 初始化
  UserRequest userRequest = UserRequest();
  bool isUserInitSucceed = await userRequest.init();
  print("UserRequest初始化: $isUserInitSucceed");
  print("UserRequest的URL: " + UserRequest.url);

  /// (3) MyBookRequest 初始化
  MyBookRequest myBookRequest = MyBookRequest();
  bool isMyBookInitSucceed = await myBookRequest.init();
  print("MyBookRequest初始化: $isMyBookInitSucceed");
  print("MyBookRequest的URL: " + MyBookRequest.url);

  /// (4) ShopRequest 初始化
  ShopRequest shopRequest = ShopRequest();
  bool isShopInitSucceed = await shopRequest.init();
  print("ShopRequest初始化: $isShopInitSucceed");
  print("ShopRequest的URL: " + ShopRequest.url);

  print("UserID = ${await LocalStorageUtils.getUserID_Local()}");
}

// TODO: 主程序入口
void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  /// 初始化器
  await App_Initializator();

  bool mainIsLogin = await LocalStorageUtils.isLogin();

  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: true,
        home: EnterPage(isLogin: mainIsLogin,), //MyLibrary(),
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          print('设备语言环境: $deviceLocale');
        },
      )
  );

  var reg = RegExp('[0-9]+(\\.[0-9]+)?', multiLine: true);
  print(Utils.dateTimeToString(DateTime.now()));
}

/* 个人图书对象示例

  MyBookModel this_Book = MyBookModel(
    coverURL: "https://img3.doubanio.com/view/subject/l/public/s25948080.jpg",
    bookName: "云雀叫了一整天",
    ISBN: "9787569377941",

    bookShelf: "书房",
    notes: "精装版",
    lender: "",
    isLentOut: false,

    buyFrom: "京东",
    buyDate: "2020-05-21",
    price: 30.00,

    author: "木心",
    translator: "陈丹青",
    press: "广西师范大学出版社",
    publicationDate: "2016-04-01",

    totalPages: 254,
    readProgress: 186,

    contentIntroduction: "《云雀叫了一整天》是由广西师范大学出版社出版的图书，作者是木心。该书由第一辑（诗歌）与第二辑（短句）组成，收入了《火车中的情诗》《女优的肖像》《伏尔加》等一百余首诗篇，逾百行木心式的精彩箴言。",
    authorIntroduction: "木心（1927年2月14日—2011年12月21日），本名孙璞，字仰中，号牧心，笔名木心。中国当代作家、画家。1927年出生于浙江省嘉兴市桐乡乌镇东栅。毕业于上海美术专科学校。2011年12月21日3时逝世于故乡乌镇，享年84岁。",
  );

*/


/* 测试图书管理的接口用的
  request.deleteShelf(shelfName: "Aunt").then((value) => print("deleteShelf : " + value.toString()));
  request.updateShelf(oldShelfName: "12", newShelfName: "Aunt").then((value) => print("updateShelf : " + value.toString()));
  request.getAuthorCount().then((value) => print("getAuthorCount : " + value.toString()));
  request.updateBook(book: this_Book).then((value) => print("updateBook : " + value.toString()));
  request.getPressCount().then((value) => print("getPressCount : " + value.toString()));
  request.getBookCountInShelf().then((value) => print("getBookCountIbShelf : " + value.toString()));
  request.getBooksFromShelf(shelfName: "Myshelf").then((value) => print("getBookFromShelf : " + value.toString()));
   request.getShelfs().then((value) => print("getShelfs : " + value.toString()));
  request.getBookByISBN(ISBN: "9787569377951").then((value) => print("getBookByISBN : " + value.toString()));
  request.getBooksByName(bookName: "aunt").then((value) => print("bookByName : " + value.toString()));
  request.addShelf(newShelfName: "shelf_aunt").then((value) => print("addShelf: " + value.toString()));
  request.deleteBook(ISBN: "9787569377941").then((value) => print("deleteBook: " + value.toString()));
  request.addBook(newBook: this_Book).then((value) => print("addbook: " + value.toString()));
  request.getAllBooks().then((value) => print(value[0].buyDate));
 */