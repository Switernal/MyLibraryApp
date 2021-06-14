
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart' show AsyncMemoizer;
import 'package:my_library/Shop/Controller/Book/PublishBookPage.dart';
import 'package:my_library/Shop/Controller/Book/ShopBookDetailPage.dart';


// Packages
import 'package:my_library/Shop/Controller/Order/BuyerOrdersPage.dart';

import 'package:my_library/Shop/Model/OrderModel.dart';
import 'package:my_library/Shop/Model/ShopBookModel.dart';
import 'package:percent_indicator/percent_indicator.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// Function
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/Shop/Function/ShopRequest.dart';


// Pages
import 'package:my_library/Shop/Controller/Order/OrderDetailPage.dart';


class GoodListCell extends StatefulWidget {

  /// 要显示的图书信息
  ShopBookModel book;

  /// 刷新订单列表
  dynamic refreshGoodsList;

  GoodListCell({@required this.book, this.refreshGoodsList});

  @override
  State<StatefulWidget> createState() => GoodListCellState();
}


class GoodListCellState extends State<GoodListCell> {

  AsyncMemoizer _memoization = AsyncMemoizer<dynamic>();

  /// 上层界面传入订单对象
  /// 这里请求订单详细数据
  /*
  Future<void> getShopBookDetail() async {
    widget.book = await ShopRequest().searchGoodByID(goodID: widget.order.bookID);
  }

   */

  // 订单号部分
  Widget GoodDetailArea() {
    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            //padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
            child: Text("商品号：" + widget.book.bookID.toString(), style: TextStyle(fontSize: 13, color: Colors.black54),),
          ),

          Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Text(widget.book.isSoldOut ? "已售出" : "待出售",
              style: TextStyle(fontSize: 15, color: Colors.red, fontWeight: FontWeight.w400),),
          ),
        ],
      ),
    );
  }

  Widget bookDetailArea() {

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                loadStateChanged: (ExtendedImageState state) {
                  return Utils.loadNetWorkImage(state);
                },
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.book.bookName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),),
                Padding(padding: EdgeInsets.all(5),),
                Row(
                  children: [
                    Text("￥", style: TextStyle(color: Colors.red, fontSize: 14,),),
                    Text(widget.book.price_now.toStringAsFixed(2), style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w700),),
                  ],
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buttonArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FlatButton(
          color: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Text("编辑", style: TextStyle(color: Colors.white),),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                PublishBookPage(bookToPublish: widget.book, publishMode: PublishMode.edit, refreshGoodsList: widget.refreshGoodsList,)
            ));
          },
        ),
        Padding(padding: EdgeInsets.all(10),),
        FlatButton(
          color: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Text("删除", style: TextStyle(color: Colors.white),),
          onPressed: () {
            Utils.ShowAlertDialog(context: context,
                title: "确定删除这本书吗",
                content: "删除后该书将从二手书店中移除",
                Action1: () async {
                  // TODO: 删除商品接口
                  int result = await ShopRequest().deleteGoods(good: widget.book);
                  switch (result) {
                    case 1:
                      Utils.showToast("删除成功", context, mode: ToastMode.Success);
                      widget.refreshGoodsList();
                      break;
                    default:
                      Utils.showToast("删除失败", context, mode: ToastMode.Error);
                      break;
                  }
                  Navigator.pop(context);
                },
                Action2: () => Navigator.pop(context));
          },
        ),
      ],
    );
  }

  // 主体部分
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

      child: Column(
        children: [
          GoodDetailArea(),
          bookDetailArea(),
          widget.book.isSoldOut ? Container() : buttonArea() // 已售出的商品不许编辑或删除
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
            ShopBookDetailPage(widget.book)
        ));
      },
      child: bodyArea(),
    );
  }
}