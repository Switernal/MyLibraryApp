
import 'package:flutter/material.dart';
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/MyBook/Controller/Book/BookInfoFormPage.dart';
import 'package:my_library/MyBook/Controller/Book/MyBookDetailPage.dart';
import 'package:my_library/MyBook/Function/SearchBookByISBN_Bamboo.dart';
import 'package:my_library/MyBook/Model/MyBookModel.dart';
import 'package:my_library/Shop/Controller/Book/PublishBookPage.dart';
import 'package:my_library/Shop/Model/ShopBookModel.dart';

import 'SearchBookByISBN_Tencent.dart';


/// 统一查询接口
/// 混合使用竹简和腾讯云接口, 提高了查到书的概率
class SearchBookByISBN {

  /// 新增一本个人藏书
  /// 先查询竹简, 再查询腾讯云, 如果都没查到则手动添加
  static Future<void> addMyBook({String ISBN, BuildContext context}) async {
    print("searchBookByISBN start");

    // 先查询Bamboo接口
    MyBookModel book = await SearchBookByISBN_Bamboo.toMyBook(ISBN, context);
    // 如果生成了书籍
    if (book != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
          MyBookDetailPage(
            isCollected: false,
            thisBook: book,
          )
      ));
    } else {  // 如果没找到书籍
      // 查询腾讯接口
      book = await SearchBookByISBN_Tencent().toMyBook(ISBN, context);

      // 如果腾讯那查到了
      if (book != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
            MyBookDetailPage(
              isCollected: false,
              thisBook: book,
            )
        ));

      } else { // 如果腾讯接口还是没找到

        Utils.ShowAlertDialog(context: context,
            title: "没有找到这本书",
            content: "是否手动添加该书？",
            color1: Colors.blue,
            Action1: () async {
              // 手动添加
              await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                return BookInfoFormPage.addfromISBN(ISBN: ISBN);
              }));

              Navigator.pop(context);
            },
            Action2: () => Navigator.pop(context));
      }

    }
  }


  /// 新增一本商店图书
  /// 先查询竹简, 再查腾讯云, 如果都没有就让换一本再试
  static Future<void> addShopBook({@required String ISBN, @required BuildContext context}) async {

    // 先查腾讯接口
    ShopBookModel book = await SearchBookByISBN_Bamboo.toShopBook(ISBN, context);

    print(book.bookName);

    // 查到了
    if (book != null) {
      print("should push");
      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
          PublishBookPage(bookToPublish: book, publishMode: PublishMode.add)
      ));
    } else { // 腾讯接口没查到
      // 再查Bamboo接口
      book = await SearchBookByISBN_Tencent().toShopBook(ISBN, context);
      // Bamboo接口找到了
      if (book != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
            PublishBookPage(bookToPublish: book, publishMode: PublishMode.add)
        ));
      } else {
        // 还是没查到
        Utils.showMessageDialog("没有找到图书信息, 换一本再试试吧!", context);
      }

    }
  }
}