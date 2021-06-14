import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart' show AsyncMemoizer;
import 'package:flutter/painting.dart';

// Functions
import 'package:my_library/Shop/Function/ShopRequest.dart';

// Models
import 'package:my_library/Shop/Model/OrderModel.dart';

// Views
import 'package:my_library/Shop/View/Order/OrderListCell.dart';

// Packages



class SellerOrdersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SellerOrdersPageState();
  }
}

class SellerOrdersPageState extends State<SellerOrdersPage> with AutomaticKeepAliveClientMixin {

  List<OrderModel> orders = [];

  ///定义异步寄存器, 用于FutureBuilder
  AsyncMemoizer _memoization = AsyncMemoizer<dynamic>();

  // 载入数据(用于初次载入数据)
  Future<void> loadData() async {
    // 获取卖出的订单
    orders = await ShopRequest().getSellerOrders();
    // 将订单按时间倒序排序
    orders.sort((order1, order2) => order2.createTime.millisecondsSinceEpoch.compareTo(order1.createTime.millisecondsSinceEpoch));
  }

  // 刷新数据(用于下拉刷新)
  Future<void> refreshData() async {

    await Future.delayed(Duration(milliseconds: 50), () async {
      // 获取卖出的订单
      orders = await ShopRequest().getSellerOrders();

      // 将订单按时间倒序排序
      orders.sort((order1, order2) => order2.createTime.millisecondsSinceEpoch.compareTo(order1.createTime.millisecondsSinceEpoch));

      setState(() {
        orders.forEach((order) async {
          order.book = await ShopRequest().searchGoodByID(goodID: order.bookID);
        });
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder(
        future: _memoization.runOnce(loadData),
        builder: (context, snapshot) {
          return orders.isEmpty ?
              // 如果没有订单
              Stack(
                children: [
                  Container(
                      color: Colors.white,
                      child: RefreshIndicator(
                          onRefresh: refreshData,
                          child: ListView(
                            shrinkWrap: false,
                            children: [

                            ],
                          )
                      )
                  ),
                  Container(
                    child: Center(
                      child: Text(
                        "没有查到订单\n\n你好像还没有卖出过图书哦",
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              )
               :
              // 有订单
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 20),
                color: Colors.white10,
                child: RefreshIndicator(
                  onRefresh: refreshData,
                  child: ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, row) {
                        return OrderListCell(
                          order: orders[row],
                          refreshOrderList: refreshData,
                          mode: OrderMode.seller,
                        );
                      }
                  ),

                ),
              );
        }
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}