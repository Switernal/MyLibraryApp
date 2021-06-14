
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart' show AsyncMemoizer;


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



class OrderListCell extends StatefulWidget {

  /// 要显示的订单信息
  OrderModel order;

  /// 刷新订单列表
  dynamic refreshOrderList;

  /// 当前模式
  OrderMode mode;

  OrderListCell({@required this.order, this.refreshOrderList, this.mode = OrderMode.buyer});

  @override
  State<StatefulWidget> createState() => OrderListCellState();
}


class OrderListCellState extends State<OrderListCell> {

  AsyncMemoizer _memoization = AsyncMemoizer<dynamic>();

  /// 上层界面传入订单对象
  /// 这里请求订单详细数据
  ///
  Future<void> getShopBookDetail() async {
    widget.order.book = await ShopRequest().searchGoodByID(goodID: widget.order.bookID);
  }

  // 订单号部分
  Widget OrderDetailArea() {
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
            child: Text("订单号：" + widget.order.orderID, style: TextStyle(fontSize: 13, color: Colors.black54),),
          ),

          Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Text(
              widget.mode == OrderMode.buyer ?
                OrderModel.orderStatusList[widget.order.orderStatus] :
                OrderModel.orderStatusList[widget.order.orderStatus]
              ,
              style: TextStyle(fontSize: 15, color: Colors.red, fontWeight: FontWeight.w400),),
          ),
        ],
      ),
    );
  }
  
  Widget bookDetailArea() {

    return FutureBuilder(
      future: getShopBookDetail(),
      builder: (context, snapshot) {
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
                    widget.order.book.coverURL,
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
                    Text(widget.order.book.bookName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),),

                    /*
                Divider(),

                widget.order.book.ISBN != "" ?
                Text("ISBN：" + widget.order.book.ISBN,
                  style: TextStyle(
                    fontSize: 12,
                  ),) : Container(padding: EdgeInsets.zero,),

                 */

                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget priceArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("实付款: ", style: TextStyle(fontSize: 13),),
        Text("￥", style: TextStyle(color: Colors.red, fontSize: 13,),),
        Text(widget.order.price.toStringAsFixed(2), style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w700),),
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
          OrderDetailArea(), 
          bookDetailArea(),
          priceArea()
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
            OrderDetailPage(widget.order, mode: widget.mode, refreshOrderList: widget.refreshOrderList)
        ));
      },
      child: bodyArea(),
    );
  }
}