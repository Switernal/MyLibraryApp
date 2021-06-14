import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:my_library/MyBook/Controller/BookShelf/(Deprecated)BookShelfManagePage.dart';
import 'package:my_library/MyBook/Model/MyBookModel.dart';
import 'package:my_library/MyBook/View/BookCard.dart';
// import 'package:suggestion_search_bar/suggestion_search_bar.dart';

// Functions
import 'package:my_library/Functions/Utils/LocalStorageUtils.dart';

// Models
import 'package:my_library/MyBook/Model/BookShelfModel.dart';


// TODO: 书架Page
class BookShelfView extends StatefulWidget {
  
  /// 书架名
  BookShelfModel shelf;
  
  BookShelfView({this.shelf}) {
    // 在书架构造时加载图书列表, 传入时的对象提供书架名即可
  }
  
  @override
  State<StatefulWidget> createState() {
    return BookShelfViewState();
  }
}


// TODO: 书架State
// 使用 with AutomaticKeepAliveClientMixin 配合wantKeepAlive方法,可以解决TabBar切换时重新build的问题
class BookShelfViewState extends State<BookShelfView> with AutomaticKeepAliveClientMixin {

  /*
  Future<void> getBooks() async {
    // print("shelf View : " + widget.shelf.shelfName);
    await LocalStorage.getBooksFromShelf_test(shelf: widget.shelf).then((value) {
      widget.shelf.books = value;
    });
  }

   */

  // TODO: build构造方法
  @override
  Widget build(BuildContext context) {

    print("BookShelfView Build: " + widget.shelf.shelfName);

    /*
    var jsonData = json.encode(widget.shelf);
    print(jsonData);
    print(BookShelfModel.fromJson(json.decode(jsonData)));
    */

    return GridView.builder(
      shrinkWrap: true,
      itemCount: widget.shelf.books.length,
      //physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 0,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        return BookCard(
            thisBook: widget.shelf.books[index],
            data: BookCardViewModel(
                bookName: widget.shelf.books[index].bookName,
                readProgress: widget.shelf.books[index].readProgress,
                coverURL: widget.shelf.books[index].coverURL,
                needVip: false
            ));
      },);

  }


  @override
  // TODO: 使用 with AutomaticKeepAliveClientMixin 配合此方法,可以解决TabBar切换时重新build的问题
  bool get wantKeepAlive => true;
}