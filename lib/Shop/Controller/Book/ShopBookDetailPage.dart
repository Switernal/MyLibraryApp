import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:my_library/Functions/Utils/LocalStorageUtils.dart';

// Controllers
import 'package:my_library/Shop/Controller/Order/PaymentPage.dart';

// Models
import 'package:my_library/Shop/Model/ShopBookModel.dart';
import 'package:my_library/User/Function/UserRequest.dart';
import 'package:my_library/User/Model/UserModel.dart';

// Packages
import 'package:blur/blur.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

// Functions
import 'package:my_library/Functions/Utils/Utils.dart';

import 'PublishBookPage.dart';


class ShopBookDetailPage extends StatefulWidget {
  
  ShopBookModel book;
  
  ShopBookDetailPage(this.book);
  
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ShopBookDetailPageState();
  }
}

class ShopBookDetailPageState extends State<ShopBookDetailPage> {

  /// 获取本用户的ID, 用于判断商品是否属于这个用户
  int userID = 0;

  /// 获取用户信息的延迟加载
  Future<void> getUserInfo() async {
    widget.book.owner = await UserRequest().getUserByID(widget.book.userID);
  }

  /// 获取用户id
  Future<void> getUserID() async {
    userID = await LocalStorageUtils.getUserID_Local();
  }

  Widget CoverArea() {

    Widget BookCover = ExtendedImage.network(
      widget.book.coverURL,
      cache: true,
      fit: BoxFit.cover,
      enableLoadState: true,
      loadStateChanged: (state) {
        return Utils.loadNetWorkImage(state);
      },
    );
    TextStyle detailTextStyle = TextStyle(color: Colors.white, fontSize: 12);

    // 三层模糊, 用于显示封面区域
    return Blur(
      blurColor: Colors.black26,
      colorOpacity: 0.4,
      blur: 1,
      child: Blur(
        blur: 5,
        //blurColor: Colors.black45,
        child: ExtendedImage.network(
          widget.book.coverURL,
          cache: true,
          scale: 2.5,
          height: 230,
          width: double.infinity,
          fit: BoxFit.fitWidth,
          enableLoadState: true,
          loadStateChanged: (state) {
            return Utils.loadNetWorkImage(state);
          },
        ),
        /*
        child: ImageBlur.network(
          widget.book.coverURL,
          scale: 2.5,
          blur: 3,
          height: 230,
          width: double.infinity,
          fit: BoxFit.fill,
          //blurColor: Colors.black45,
        ),

         */
      ),
      overlay: Container(
        //height: 200,
        alignment: Alignment.center,

        // 封面图片
        child: AspectRatio(
          aspectRatio: 3.0 / 3.8, // 宽高比
          child: Container(
            child: BookCover,
            margin: EdgeInsets.fromLTRB(30, 20, 20, 20),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  // 用户信息区域
  Widget UserArea() {
    return FutureBuilder(
      future: getUserInfo(),
      builder: (context, snapshot) {
        return Container(
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          //padding: EdgeInsets.only(top: 10, left: 10, bottom: 10, right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 15),
                      height: 40,
                      width: 40,
                      child: CircleAvatar(child: Icon(Icons.person, size: 27,)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.book.owner.userName),
                        Text(
                          "发布于" + Utils.timeDiffrence_DateTime(widget.book.createTime),
                          style: TextStyle(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(),
            ],
          )
        );
     });

  }


  // 图书商品详情区域
  Widget DetailArea() {
    double leftPadding = 20;
    double topPadding = 2;
    double bottomPadding = 2;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 书名
          Padding(
            padding: EdgeInsets.only(top: 20, left: 20, bottom: 5, right: 20),
            child: Text(
              widget.book.bookName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),

          // 现价
          Padding(
            // padding的left设为16, 而不是20, 不然￥对不齐左边
            padding: EdgeInsets.only(top: 5, left: 16, bottom: 10, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  // 使用toStringAsFixed设定小数位数
                  "￥" + widget.book.price_now.toStringAsFixed(2),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: "Arial",
                    letterSpacing: -0.5,
                  ),
                ),
                // 打折数
                // 如果原价为0, 就不显示折扣, 否则会计算出错
                // 不能为0折或大于10折
                widget.book.price_origin != 0 && (widget.book.price_now / widget.book.price_origin < 1 && widget.book.price_now / widget.book.price_origin > 0) ?
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    padding: EdgeInsets.symmetric(vertical: 2 , horizontal: 5),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Text(
                      // 这里, 原价不能为 0
                        "二手" + (widget.book.price_now / widget.book.price_origin * 10).toStringAsFixed(1) + "折",
                      style: TextStyle(
                          letterSpacing: 0.5,
                          color: Colors.red,
                          fontSize: 13,
                        ),
                    ),
                  ) : Container(),
                widget.book.expressPrice == 0.0 ?
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    padding: EdgeInsets.symmetric(vertical: 2 , horizontal: 5),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Text(
                      "包邮",
                      style: TextStyle(
                        letterSpacing: 0.5,
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ) : Container(),
              ],
            ),
          ),

          // 其它详细信息
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 品相
              Padding(
                padding: EdgeInsets.only(left: leftPadding, top: topPadding, bottom: bottomPadding),
                child: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(text: "品   相：", style: TextStyle(color: Colors.grey)),
                      TextSpan(text: ShopBookModel.appearanceList[widget.book.appearance], style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ),

              // 原价
              Padding(
                padding: EdgeInsets.only(left: leftPadding, top: topPadding, bottom: bottomPadding),
                child: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(text: "原   价：", style: TextStyle(color: Colors.grey)),
                      TextSpan(text: "￥" + widget.book.price_origin.toStringAsFixed(2), style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ),

              // 作者
              Padding(
                padding: EdgeInsets.only(left: leftPadding, top: topPadding, bottom: bottomPadding),
                child: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(text: "作   者：", style: TextStyle(color: Colors.grey, )),
                      TextSpan(text: widget.book.author == "" ? "暂无" : widget.book.author, style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ),

              // 译者(如果没有译者, 返回一个Container)
              /*
              widget.book.translator == "" ? Padding(
                padding: EdgeInsets.only(left: leftPadding, top: topPadding, bottom: bottomPadding),
                child: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(text: "译   者：", style: TextStyle(color: Colors.grey)),
                      TextSpan(text: widget.book.translator, style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ) : Container(height: 0, width: 0,),

               */


              // 出版时间
              Padding(
                padding: EdgeInsets.only(left: leftPadding, top: topPadding, bottom: bottomPadding),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: "出   版：", style: TextStyle(color: Colors.grey),),
                      TextSpan(text: widget.book.publicationDate == "" ? "暂无" : widget.book.publicationDate, style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ),

              // 出版社
              Padding(
                padding: EdgeInsets.only(left: leftPadding, top: topPadding, bottom: bottomPadding),
                child: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      // (letterSpacing 设置为-0.6, 才能与上面的文字对齐, 不知道怎么处理中文字符长度, 不过这样能用)
                      TextSpan(text: "出版社：", style: TextStyle(color: Colors.grey, letterSpacing: -0.6)),
                      TextSpan(text: widget.book.press == "" ? "暂无" : widget.book.press, style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // 内容区域
  Widget ContentArea() {

    return Container(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("内容简介", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            Text(widget.book.introduction == "" ? "暂无内容简介" : widget.book.introduction, textAlign: TextAlign.left,),

          ],
        ),
      ),
    );
  }

  // 底部固定栏,购买和购物车按钮
  Widget BottomNavigationArea() {
    return FutureBuilder(
        future: getUserID(),
        builder: (context, snapshot) {
          return Container(
            height: 85,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                  top: BorderSide( // 设置单侧边框的样式
                  color: Colors.grey,
                  width: 0.3,
                  style: BorderStyle.solid,
                 )
              )
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 10, bottom: 25),
              child:Row(
                children: [
                  /*
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.only(left: 30, right: 15),
                  child: RaisedButton(
                    child: Text("加入购物车", style: TextStyle(color: Colors.white),),
                    color: Colors.red[300],
                    onPressed: () {},),
                ),
              ),

               */
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(left: 15, right: 30, ),
                      child:
                      widget.book.isSoldOut == false ?
                      (
                          widget.book.userID == this.userID ?
                          OutlineButton(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                            child: Text("管理", style: TextStyle(color: Colors.black),),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                                  PublishBookPage(bookToPublish: widget.book, publishMode: PublishMode.edit, refreshGoodsList: () {setState(() {});},)
                              ));
                            },
                          ) :
                          FlatButton(
                            color: Colors.deepOrange,
                            //colorBrightness: Brightness.dark,
                            //splashColor: Colors.blueAccent,
                            shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                            child: Text("立即购买", style: TextStyle(color: Colors.white),),
                            onPressed: () {
                              /*
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                                  PaymentPage(widget.book)));

                               */
                              // 返回首页路由配置
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => PaymentPage(widget.book)),
                                      (Route<dynamic> route) {
                                    //返回的是false的都会被从路由队列里面清除掉
                                    return route.isFirst;
                                  });
                            },
                          )
                      ) :
                      FlatButton(
                        color: Colors.deepOrange,
                        disabledColor: Colors.black45,
                        //colorBrightness: Brightness.dark,
                        //splashColor: Colors.blueAccent,
                        shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                        child: Text("卖掉了", style: TextStyle(color: Colors.white),),

                      ),

                      /*
                  RaisedButton(
                    child: Text("立即购买", style: TextStyle(color: Colors.white),),
                    color: Colors.deepOrange,
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                          PaymentPage()
                      ));
                    },
                  ),

                   */
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("二手书详情"),),
      bottomNavigationBar: BottomNavigationArea(),
      body: ListView(
        primary: false,
        children: [
          CoverArea(),
          UserArea(),
          DetailArea(),
          Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, 0), child: Divider(),),
          ContentArea(),
        ],
      ),
    );
  }
}