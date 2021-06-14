import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

// Packges
import 'package:blur/blur.dart';
import 'package:my_library/MyBook/Controller/Book/MyBookEditReadProgressPage.dart';
import 'package:my_library/MyBook/Controller/Book/MyBookEditLentOutPage.dart';
import 'package:my_library/MyBook/Controller/Book/BookInfoFormPage.dart';
import 'package:my_library/Functions/Utils/LocalStorageUtils.dart';
import 'package:my_library/MyBook/Function/MyBookRequest.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// Models
import 'package:my_library/MyBook/Model/MyBookModel.dart';

// Functions
import 'package:my_library/Functions/Utils/Utils.dart';


// 测试用数据
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

  totalPages: 0,
  readProgress: 0,

  contentIntroduction: "《云雀叫了一整天》是由广西师范大学出版社出版的图书，作者是木心。该书由第一辑（诗歌）与第二辑（短句）组成，收入了《火车中的情诗》《女优的肖像》《伏尔加》等一百余首诗篇，逾百行木心式的精彩箴言。",
  authorIntroduction: "木心（1927年2月14日—2011年12月21日），本名孙璞，字仰中，号牧心，笔名木心。中国当代作家、画家。1927年出生于浙江省嘉兴市桐乡乌镇东栅。毕业于上海美术专科学校。2011年12月21日3时逝世于故乡乌镇，享年84岁。",
);

class MyBookDetailPage extends StatefulWidget {

  // 是否已经收藏
  bool isCollected = true;

  // 当前显示的书
  MyBookModel thisBook;

  MyBookDetailPage({this.isCollected, this.thisBook});

  @override
  State<StatefulWidget> createState() {
    return MyBookDetailPageState();
  }
}

class MyBookDetailPageState extends State<MyBookDetailPage> {

  GlobalKey gbkey1 = GlobalKey();
  GlobalKey gbkey2 = GlobalKey();
  double containerHeight = 0.0;

  // 网络请求对象
  var request = MyBookRequest();

  // 刷新阅读进度
  void refreshReadProgress(int progress) {
    setState(() {
     widget.thisBook.readProgress = progress;
    });
  }

  // 刷新借出人
  void refreshLentOut(String lender) {
    setState(() {
      widget.thisBook.lender = lender;
      if (widget.thisBook.lender != "") {
        widget.thisBook.isLentOut = true;
      } else {
        widget.thisBook.isLentOut = false;
      }
    });
  }
  
  // 改变收藏状态
  void changeCollectionButtonStatus() {
    setState(() {
      widget.isCollected = !widget.isCollected;
    });
  }

  Widget CoverArea() {

    print("Cover Area");

    Widget BookCover = ExtendedImage.network(
      widget.thisBook.coverURL,
      fit: BoxFit.fill,
      enableLoadState: true,
      loadStateChanged: (state) {
        return Utils.loadNetWorkImage(state);
      },
    );
    /*
    CachedNetworkImage(
      imageUrl: widget.thisBook.coverURL,
      fit: BoxFit.fill,
      // placeholder: (context, url) => Container(padding: EdgeInsets.all(20),child: Center(child: AspectRatio(aspectRatio: 1, child: CircularProgressIndicator(strokeWidth: 4,),),),),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );

     */

    /*
    Image.network(
      widget.thisBook.coverURL,
      fit: BoxFit.fill,
    );

     */
    TextStyle detailTextStyle = TextStyle(color: Colors.white, fontSize: 12);

    // 三层模糊
    var thisWidget = Blur(

      blurColor: Colors.black26,
      colorOpacity: 0.4,
      blur: 1,
      child: Blur(
        blur: 1,
        //blurColor: Colors.black45,
        child: Blur(
          blur: 3,
          child: ExtendedImage.network(
            widget.thisBook.coverURL,
            cache: true,
            scale: 2.5,
            width: double.infinity,
            height: containerHeight + 20,
            fit: BoxFit.fill,
            enableLoadState: true,
            loadStateChanged: (state) {
              return Utils.loadNetWorkImage(state);
            },
          ),
        ),
        /*
        ImageBlur.network(
          widget.thisBook.coverURL,
          scale: 2.5,
          blur: 3,
          width: double.infinity,
          height: containerHeight + 20,
          fit: BoxFit.fill,
          //blurColor: Colors.black45,
        ),
         */
      ),
      overlay: Container(

        //height: 200,
        padding: EdgeInsets.only(bottom: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            // image: DecorationImage(
            //     image: NetworkImage(
            //       "https://ss0.baidu.com/94o3dSag_xI4khGko9WTAnF6hhy/baike/w=268/sign=c43f567497dda144da096bb48ab6d009/a6efce1b9d16fdfa67b93489b48f8c5495ee7b84.jpg",
            //     ),
            //     fit: BoxFit.fitWidth),
            ),
        // 左右摆放图片和文字
        child: Column(

          children: [
            Row(
              key: gbkey1,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 图片(宽高比)
                Expanded(
                  flex: 3,
                  child: AspectRatio(
                    aspectRatio: 3.0 / 3.8, // 宽高比
                    child: Container(
                      child: BookCover,
                      margin: EdgeInsets.fromLTRB(30, 20, 20, 20),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),

                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 30, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.thisBook.bookName,
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),

                        ),
                        Divider(height: 10, color: Colors.white,),
                        //Padding(padding: EdgeInsets.symmetric(vertical: 5)),

                        widget.thisBook.author != "" ? Text(
                          "作者：" + widget.thisBook.author,
                          style: detailTextStyle,
                        ) : Container(),

                        widget.thisBook.translator != "" ? Column(
                          children: [
                            Padding(padding: EdgeInsets.symmetric(vertical: 1)),
                            Text(
                              "译者：" + widget.thisBook.translator,
                              style: detailTextStyle,
                            )
                          ],
                        ) : Container(),

                        widget.thisBook.price != 0.00 ? Column(
                          children: [
                            Padding(padding: EdgeInsets.symmetric(vertical: 1)),
                            Text(
                              "定价：" + widget.thisBook.price.toStringAsFixed(2),
                              style: detailTextStyle,
                            ),
                          ],
                        ): Container(),

                        widget.thisBook.press != "" ? Column(
                          children: [
                            Padding(padding: EdgeInsets.symmetric(vertical: 1)),
                            Text(
                              "出版社：" + widget.thisBook.press,
                              style: detailTextStyle,
                            ),
                          ],
                        ): Container(),


                        Padding(padding: EdgeInsets.symmetric(vertical: 1)),
                        Text(
                          "ISBN：" + widget.thisBook.ISBN,
                          style: detailTextStyle,
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 15),
                          child: RaisedButton(
                            color: Colors.white,
                            child: (widget.isCollected == true) ?
                              Text("已收藏", style: TextStyle(color: Colors.black54),):
                              Text("收藏", style: TextStyle(color: Colors.blue),)
                            ,
                            onPressed: () async {
                              if (widget.isCollected == false) {
                                // 上传新书到数据库
                                // 上传操作...(shelf 默认)
                                // LocalStorage.saveSearchedBook_test(newBook: widget.thisBook);

                                // 新增图书操作
                                Utils.showToast("更新中...", context, mode: ToastMode.Loading);
                                var result = await request.addBook(newBook: widget.thisBook);
                                switch (result) {
                                  case 1:
                                    Utils.showToast("收藏成功", context, mode: ToastMode.Success);
                                    break;
                                  case 0:
                                    Utils.showToast("收藏失败, 已经收藏过了", context, mode: ToastMode.Error);
                                    break;
                                  default:
                                    Utils.showToast("发生未知错误", context, mode: ToastMode.Error);
                                }

                                // 更新按钮
                                changeCollectionButtonStatus();

                              } else {
                                Utils.ShowAlertDialog(
                                  context: context,
                                  title: "确定取消收藏《${widget.thisBook.bookName}》吗",
                                  content: "取消收藏该书将从我的书藏中移除该书",
                                  Action1: () async {
                                    // 确定按钮, 删除该书
                                    // ... 删除操作
                                    /*
                                    LocalStorage.removeBook_ISBN_test(widget.thisBook.ISBN, widget.thisBook.bookShelf).then(
                                            (value) => value == true ?
                                            Utils.showToast("取消收藏成功", context) : Utils.showToast("取消收藏失败了...", context)
                                    );

                                     */
                                    Utils.showToast("更新中...", context, mode: ToastMode.Loading);
                                    // 删除图书操作
                                    var result = await request.deleteBook(ISBN: widget.thisBook.ISBN);
                                    switch (result) {
                                      case 1:
                                        Utils.showToast("取消收藏成功", context, mode: ToastMode.Success);
                                        break;
                                      case 0:
                                        Utils.showToast("取消收藏失败", context, mode: ToastMode.Error);
                                        break;
                                      default:
                                        Utils.showToast("发生未知错误", context, mode: ToastMode.Error);
                                    }
                                    Navigator.pop(context);
                                    // 更新按钮状态
                                    changeCollectionButtonStatus();
                                  },
                                  Action2: () => Navigator.pop(context),
                                );
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ButtonArea(),
          ],
        ),
      ),
    );

    return thisWidget;
  }

  Widget ButtonArea() {

    return Container(
      key: gbkey2,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
            child: RaisedButton(
              color: Colors.lightBlueAccent,
              child: (widget.thisBook.readProgress == 0) ?
                Text("设置阅读状态", style: TextStyle(color: Colors.white),) :
                (widget.thisBook.totalPages == 0 ?
                  Text("在读（第" + widget.thisBook.readProgress.toString() + "页）", style: TextStyle(color: Colors.white),) :
                  Text("在读（" + widget.thisBook.readProgress.toString() + "/" + widget.thisBook.totalPages.toString() + "）", style: TextStyle(color: Colors.white),)
                ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  MyBookEditReadProgressPage(
                    refreshReadProgress: refreshReadProgress,
                    readProgress: widget.thisBook.readProgress,
                    book: widget.thisBook,
                  )
                ));
              },
            ),
          ),),
          Expanded(child: Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
            child: RaisedButton(
              color: Colors.lightBlue,
              child: widget.thisBook.isLentOut == false ?
                Text("设置借出状态", style: TextStyle(color: Colors.white),) :
                Text("已借给" + widget.thisBook.lender, style: TextStyle(color: Colors.white),)
              ,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                    MyBookEditLentOutPage(
                      refreshLentOut: refreshLentOut,
                      lender: widget.thisBook.lender,
                      book: widget.thisBook,
                    )
                ));
              },
            ),
          ),)
,        ],
      ),
    );
  }

  Widget ContentArea() {

    return Container(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("出版日期", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            Text(widget.thisBook.publicationDate == "" ? "暂无出版日期" : widget.thisBook.publicationDate,
                /*
                  DateTime.tryParse(widget.thisBook.publicationDate).year.toString() + "年" +
                  DateTime.tryParse(widget.thisBook.publicationDate).month.toString() + "月",

                 */
              textAlign: TextAlign.left,),

            Padding(padding: EdgeInsets.symmetric(vertical: 10)),

            Text("内容简介", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            Text(
              widget.thisBook.contentIntroduction == "" ? "暂无简介" : widget.thisBook.contentIntroduction,
              textAlign: TextAlign.left,),

            Padding(padding: EdgeInsets.symmetric(vertical: 10)),

            Text("作者简介", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            Text(widget.thisBook.authorIntroduction == "" ? "暂无简介" : widget.thisBook.authorIntroduction,
              textAlign: TextAlign.left,),
          ],
        ),
      ),
    );
  }


  Future<void> executeAfterBuild() async {

    print("build Complete");
    print(gbkey1.currentContext.size.height);
    print(gbkey2.currentContext.size.height);
    setState(() {
      print("set state");
      containerHeight = gbkey1.currentContext.size.height + gbkey2.currentContext.size.height;
      print(containerHeight);
    });
  }

  Future<void> initialization() async {
    // 初始化请求对象
    await request.init();

    // 如果传入时是未收藏, 也就是扫码进入的, 看一下是不是已存在
    if (widget.isCollected == false) {
      var result = await request.getBookByISBN(ISBN: widget.thisBook.ISBN);
      //setState(() {
        if (result != null) {
          widget.isCollected = true;
        } else {
          widget.isCollected = false;
        }
     //});
    }
  }

  // 监听单次Frame绘制后回调, 更新Container, height
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((callback){
      print("addPostFrameCallback be invoke");
      setState(() {
        containerHeight = gbkey1.currentContext.size.height + gbkey2.currentContext.size.height;
        print(containerHeight);
      });
    });

  }

  @override
  Widget build(BuildContext context) {

    print("MyBookDetail Build");

    return Scaffold(
      appBar: AppBar(
        title: Text("书籍详情"),
        actions: [
          // FlatButton(onPressed: () {}, child: Icon(Icons.edit))
        ],
      ),
      // 如果没收藏,不显示编辑按钮
      floatingActionButton: widget.isCollected ? FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () async {
          widget.thisBook = await Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
              BookInfoFormPage.edit(book: widget.thisBook)
          )) ?? widget.thisBook ;
          setState(() {});
        },
      ) : Container(),

      // ListView 可滚动, 组件作为ListView的Children
      body: FutureBuilder(
        future: initialization(),
        builder: (context, snapshot) {
          return ListView(
            children: [
              CoverArea(),
              //ButtonArea(),
              ContentArea(),
            ],
          );
        }
      ),
    );
  }

}