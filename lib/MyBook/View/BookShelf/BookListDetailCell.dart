
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:my_library/MyBook/Controller/BookShelf/BookShelfEditPage.dart';

// Packages
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:my_library/MyBook/Controller/Book/BookInfoFormPage.dart';
import 'package:my_library/MyBook/Controller/Book/MyBookDetailPage.dart';
import 'package:percent_indicator/percent_indicator.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// Function
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/MyBook/Function/MyBookRequest.dart';
import 'package:my_library/MyBook/Model/MyBookModel.dart';



class BookListDetailCell extends StatefulWidget {

  // 显示的书籍
  MyBookModel book;

  // 删除更新书柜界面操作
  dynamic deleteRefreshAction;

  BookListDetailCell({this.deleteRefreshAction, @required this.book});

  @override
  State<StatefulWidget> createState() => BookListDetailCellState();
}

class BookListDetailCellState extends State<BookListDetailCell> {

  Widget bodyArea() {
    return Container(

      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            spreadRadius: 2,
            color: Color.fromARGB(20, 0, 0, 0),
          ),
        ],
      ),

      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: AspectRatio(
              aspectRatio: 3.0 / 3.8, // 宽高比
              child: Container(
                //height: 20,
                padding: EdgeInsets.zero,
                child: ExtendedImage.network(
                  widget.book.coverURL,
                  cache: true,
                  fit: BoxFit.fitHeight,
                  enableLoadState: true,
                  loadStateChanged: (state) {
                    return Utils.loadNetWorkImage(state);
                  },
                ),
                /*
                CachedNetworkImage(
                  imageUrl: widget.book.coverURL,
                  fit: BoxFit.fitHeight,
                  // placeholder: (context, url) => Container(padding: EdgeInsets.all(20),child: Center(child: AspectRatio(aspectRatio: 1, child: CircularProgressIndicator(strokeWidth: 4,),),),),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                //Image(image: NetworkImage(), fit: ,),
                */

              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(left: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.book.bookName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),),

                  Divider(),

                  widget.book.author != "" ?
                  Text("作者：" + widget.book.author,
                    style: TextStyle(
                      fontSize: 12,
                    ),) : Container(padding: EdgeInsets.zero,),


                  widget.book.totalPages != 0 && widget.book.readProgress != 0 ?
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("阅读进度：", style: TextStyle(fontSize: 12,),),
                        Expanded(child: LinearPercentIndicator(
                          lineHeight: 5,
                          percent: (double.parse(widget.book.readProgress.toString())) / (double.parse(widget.book.totalPages.toString())),
                          progressColor: Colors.blue,
                          backgroundColor: Colors.black12,
                        )),
                        Text(widget.book.readProgress.toString() + " / " + widget.book.totalPages.toString(),
                          style: TextStyle(fontSize: 12),),
                      ],),
                  ) :
                  widget.book.readProgress != 0 ?
                  Text("阅读进度：第 " + widget.book.readProgress.toString() + " 页",
                    style: TextStyle(
                      fontSize: 12,
                    ),) : Container(padding: EdgeInsets.zero,),

                  widget.book.ISBN != "" ?
                  Text("ISBN：" + widget.book.ISBN,
                    style: TextStyle(
                    fontSize: 12,
                  ),) : Container(padding: EdgeInsets.zero,),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
            MyBookDetailPage(thisBook: widget.book, isCollected: true,)
        ));
      },
      child: Slidable(
        child: bodyArea(),
        // 使用Drawer滑动菜单风格
        actionPane: SlidableDrawerActionPane(),
        // 左侧菜单
        actions: [
          // 编辑按钮
          IconSlideAction(
            caption: '编辑',
            color: Colors.blue,
            icon: Icons.edit,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  BookInfoFormPage.edit(book: widget.book,)
              ));
            },
          ),

        ],
        actionExtentRatio: 0.25,
        // 右侧菜单
        secondaryActions: [
          IconSlideAction(
            caption: '取消收藏',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {
              Utils.ShowAlertDialog(context: context,
                title: "确定取消收藏《${widget.book.bookName}》吗",
                content: "取消收藏后《${widget.book.bookName}》将从您的藏书中移除",
                Action1: () async {
                  Utils.showToast("更新中...", context, mode: ToastMode.Loading, duration: 5);

                  var request = MyBookRequest();
                  await request.init();
                  var result = await request.deleteBook(ISBN: widget.book.ISBN);
                  switch (result) {
                    case 1:
                      Utils.showToast("取消收藏成功", context);
                      widget.deleteRefreshAction();
                      break;
                    case 0:
                      Utils.showToast("取消收藏失败", context);
                      break;
                    default:
                      Utils.showToast("发生未知错误", context);
                  }
                  Navigator.pop(context);
                },
                Action2: () => Navigator.pop(context),
              );
            },

          ),
        ],
      ),
    );
  }
}