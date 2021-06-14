import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:my_library/MyBook/Model/BookShelfModel.dart';
import 'package:my_library/MyBook/Model/MyBookModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:permission_handler/permission_handler.dart';

Map<String, String> keys = {
  "BookShelfs" : "BookShelfs",
};

// 本地数据存储辅助类(使用 Shared_Preferences)
class LocalStorageUtils {

  // 初始化
  static Future<bool> initLocalStorage() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.reload();

    // 设置版本信息
    bool version = await prefs.setString("Version", Utils.Version);
    //print("vsersion ${version}");
    prefs.setString("UpdateDate", Utils.UpdateDate);

    // 设置App首次启动时间
    if (!prefs.containsKey("firstLaunchTime")) {
      prefs.setString("firstLaunchTime", DateTime.now().toString());
    }

    // 设置书柜
    if (!prefs.containsKey(keys["BookShelfs"])) {
      // 没有书柜信息
      prefs.setStringList(keys["BookShelfs"], ["所有藏书"]);
      prefs.setString("Shelf_所有藏书", json.encode(BookShelfModel(shelfName: "所有藏书")));
    }

    // 默认书柜
    if (!prefs.containsKey("DefaultBookShelf")) {
      prefs.setString("DefaultBookShelf", "所有藏书");
    }

    // 设置登录状态
    if (!prefs.containsKey("isLogin")) {
      return prefs.setBool("isLogin", false);
    } else {
      return true;
    }

  }

  // 获取初始化状态
  static Future<void> getInitializationString() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.reload();

    if (!prefs.containsKey("firstLaunchTime")) {
      return;
    }

    print("版本: " + prefs.getString("Version"));
    print("更新日期: " + prefs.getString("UpdateDate"));
    return;
  }

  // 是否首次启动App
  static Future<bool> isFirstLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey("firstLaunchTime");
  }

  // 用户登录
  static Future<bool> userLogin({String userName, String userPasswd, String userEmail, String userPhone, int userID}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("UserName", userName);
      prefs.setString("Email", userEmail);
      prefs.setString("Phone", userPhone);
      prefs.setString("Password", userPasswd);
      prefs.setInt("UserID", userID);
    return prefs.setBool("isLogin", true);
  }

  // 用户登出
  static Future<bool> userLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("UserName");
    prefs.remove("Password");
    prefs.remove("Email");
    prefs.remove("Phone");
    prefs.remove("UserID");
    return prefs.setBool("isLogin", false);
  }

  /// 判断用户是否登录
  static Future<bool> isLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLogin");
  }

  /// 获取用户名
  static Future<String> getUserName_Local() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.getBool("isLogin")) {
      return null;
    }
    return prefs.getString("UserName");
  }

  /// 判断输入密码和存储的加密密码是否相同
  static Future<bool> isPasswdCorrect(String userPasswd) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.getBool("isLogin")) {
      return false;
    }
    return (Utils.EncryptPassword(userPasswd) == prefs.getString("Password"));
  }

  /// 获取邮箱
  static Future<String> getUserEmail_Local() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.getBool("isLogin")) {
      return null;
    }
    return prefs.getString("Email");
  }

  /// 获取手机号
  static Future<String> getUserPhone_Local() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.getBool("isLogin")) {
      return null;
    }
    return prefs.getString("Phone");
  }

  /// 获取用户ID
  static Future<int> getUserID_Local() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // if (!prefs.getBool("isLogin")) {
    //   return null;
    // }
    return prefs.getInt("UserID");
  }

  // 登录判断是否正确
  static Future<int> Validate(String userName, String userPasswd) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (userName != prefs.getString("UserName")) {
      // 用户不存在
      return -1;
    } else {
      if (userPasswd != prefs.getString("Password")) {
        // 密码不正确
        return 0;
      }
    }

    // 登录成功
    return 1;

  }

  // 存储新用户
  static Future<bool> SaveUser(String userName, String userPasswd) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 如果用户已存在,返回false
    if (prefs.containsKey(userName) == true) {
      return false;
    }
    // 返回注册用户存储结果
    Future<bool> result = prefs.setString(userName, userPasswd);
    return result;
  }

  // 清空所有内容
  static Future<bool> clearAllUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Future<bool> result = prefs.clear();
    return result;
  }

  // TODO: 本地图书存储 (仅测试用)
  
  /// 从本地获取一个Shelf对象
  static Future<BookShelfModel> getShelfByName_test({@required String shelfName}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (shelfName == "" || shelfName == null) {
      // 获取默认书架
      var defaultShelfName = await getDefaultShelf();
      shelfName = defaultShelfName;
    }

    print("shelfName =" + shelfName );

    // 读书架数据
    var shelfJson = await prefs.getString("Shelf_" + shelfName);

    // 将json解析
    var shelfData = json.decode(shelfJson);
    // 转换成shelf对象
    BookShelfModel shelf = BookShelfModel.fromJson_Local(shelfData);

    return shelf;
  }

  /// 存扫码图书到本地
  static Future<bool> saveSearchedBook_test({@required MyBookModel newBook}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 获取默认书架对象
    var defaultShelf = await getDefaultShelf();
    // 读书架数据
    var shelfJson = await prefs.getString("Shelf_" + defaultShelf);
    // 将json解析
    var shelfData = json.decode(shelfJson);
    // 转换成shelf对象
    BookShelfModel shelf = BookShelfModel.fromJson_Local(shelfData);
    
    // 如果书架是空的, 先初始化
    // if (shelf.books == null) shelf.books = [];
    List<MyBookModel> books = await getBooksFromShelf_test(shelf: shelf);
    // 如果图书已经存在,不添加
    for (var book in books) {
      if (book.ISBN == newBook.ISBN) {
        return false;
      }
    }
    // shelf的books里添加图书
    shelf.books.add(newBook);
    // 图书数+1
    shelf.counts++;
    // 转成json
    var newJson = json.encode(shelf);

    // 存起来
    return prefs.setString("Shelf_" + defaultShelf, newJson);
  }

  /// 删除藏书(取消收藏) [目前仅默认书柜可以]
  static Future<bool> removeBook_ISBN_test(@required String ISBN, @required String shelfName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 如果传入的书柜参数为空或""
    if (shelfName == "" || shelfName == null) {
      // 获取默认书架对象
      var defaultShelf = await getDefaultShelf();
      shelfName = defaultShelf;
    }

    // 读书架数据
    var shelfJson = await prefs.getString("Shelf_" + shelfName);
    // 将json解析
    var shelfData = json.decode(shelfJson);
    // 转换成shelf对象
    BookShelfModel shelf = BookShelfModel.fromJson_Local(shelfData);

    // 如果书架是空的, 先初始化
    // if (shelf.books == null) shelf.books = [];
    List<MyBookModel> books = await getBooksFromShelf_test(shelf: shelf);

    shelf.books = books;

    // 如果找到了ISBN, 则删除
    for (var book in shelf.books) {
      if (book.ISBN == ISBN) {
        shelf.books.remove(book);
        // 图书-1
        shelf.counts--;
        // 转成json
        var newJson = json.encode(shelf);
        // 存起来
        return prefs.setString("Shelf_" + shelfName, newJson);
      }
    }
    // 如果没找到ISBN, 则
    return false;
  }

  /// 本地书柜管理
  /// 新增书柜(false: 已存在书柜)
  static Future<bool> addNewShelf_test(@required String newShelfName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 修改书架列表
    var shelfNames = await getShelfsNames_test();
    if (shelfNames.contains(newShelfName)) {
      return false;
    } else {
      shelfNames.add(newShelfName);
      // 新增书架字段
      prefs.setString("Shelf_${newShelfName}", json.encode(BookShelfModel(shelfName: newShelfName)));

      return prefs.setStringList(keys["BookShelfs"], shelfNames);
    }
  }
  
  

  /// 获取默认书柜
  static Future<String> getDefaultShelf() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("DefaultBookShelf");
  }

  /// 获取书柜名列表(String List)
  static Future<List<String>> getShelfsNames_test() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> shelfNames = await prefs.getStringList(keys["BookShelfs"]);
    return shelfNames;
  }

  /// 获取书柜列表(BookShelfModel List)
  static Future<List<BookShelfModel>> getShelfs_test() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> shelfNames = await prefs.getStringList(keys["BookShelfs"]);

    List<BookShelfModel> bookShelfs = [];
    for (var shelfname in shelfNames) {
      bookShelfs.add(BookShelfModel(shelfName: shelfname));
      // print("getShelfs_test() : " + bookShelfs.toString());
    }

    // print("getShelfs_test() : " + bookShelfs.toString());
    return bookShelfs;
  }

  /// 获取书柜里的书
  static Future<List<MyBookModel>> getBooksFromShelf_test({@required BookShelfModel shelf}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 获取书架里的数据
    var booksJson = prefs.getString("Shelf_" + shelf.shelfName);

    // 进行json解析
    var booksData = json.decode(booksJson);

    List<MyBookModel> books = [];

    // 遍历, 将书依次加入books列表
    for (var book in booksData["books"]) {
      books.add(MyBookModel.fromJson_Local(book));
    }
    // 返回列表
    return books;
  }

  /// 获取藏书总数
  static Future<int> getTotalNumber_test() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var defaultShelfName = await getDefaultShelf();
    var defaultShelf = BookShelfModel(shelfName: defaultShelfName);
    var books = await getBooksFromShelf_test(shelf: defaultShelf);
    var total = books.length;
    print("total = " + total.toString());
    return total;
  }


  /// 修改内容
 static Future<bool> setShelfs_test() {

 }

 static Future<bool> setBooksInShelf_test() {

 }

 /// 删除书柜
 static Future<bool> removeBookShelf(String shelfName) async {

   SharedPreferences prefs = await SharedPreferences.getInstance();
   // 获取默认书架
    var defaultShelfName = await getDefaultShelf();

    // 如果要删除的书架是默认书架,直接false
    if (shelfName == defaultShelfName) {
      return false;
    }

    // 获取书架列表
    var shelfNames = await getShelfsNames_test();
    // 删除书架列表中的书架名
    shelfNames.remove(shelfName);

    // 删除书架对应存储的信息
    prefs.remove("Shelf_" + shelfName);
    // 重新保存书架列表
    return prefs.setStringList(keys["BookShelfs"], shelfNames);
 }


}