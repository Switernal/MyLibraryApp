import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_library/Drawer/DrawerPage.dart';
import 'package:my_library/Shop/Function/ShopRequest.dart';
import 'package:my_library/Shop/Model/ShopBookModel.dart';
import 'package:async/async.dart' show AsyncMemoizer;
// Model
import 'package:my_library/Shop/Model/OrderModel.dart';
import 'package:my_library/User/Model/UserModel.dart';

// Views
import 'package:my_library/Shop/View/Order/OrderListCell.dart';

// Packages
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';


OrderModel order = OrderModel(
    orderID: DateTime.now().millisecondsSinceEpoch.toString(),
    bookID: 1,
    userID: 1,
    createTime: DateTime.now(),
    price: 12.80,
    consigneeName: "阿姨",
    consigneePhone: "13776155895",
    consigneeAddress: "江苏省南京市浦口区宁六路219号南京信息工程大学",
    orderStatus: 1,
    expressNumber: "4314603560948",
    book: ShopBookModel(
        bookID: 1,
        userID: 1,
        owner: UserModel(userName: "Aunt"),
        createTime: DateTime.now(),
        coverURL: "https://img3.doubanio.com/view/subject/l/public/s25948080.jpg",//"https://www.hualigs.cn/image/60bcfe294addc.jpg",
        bookName: "云雀叫了一整天",
        ISBN: "1234567890"
    ),
);

class BuyerOrdersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BuyerOrdersPageState();
  }
}

class BuyerOrdersPageState extends State<BuyerOrdersPage> with AutomaticKeepAliveClientMixin {

  List<OrderModel> orders = [];

  ///定义异步寄存器, 用于FutureBuilder
  AsyncMemoizer _memoization = AsyncMemoizer<dynamic>();


  // 载入数据(用于初次载入数据)
  Future<void> loadData() async {
    orders = await ShopRequest().getBuyerOrders();
    // 将订单按时间倒序排序
    orders.sort((order1, order2) => order2.createTime.millisecondsSinceEpoch.compareTo(order1.createTime.millisecondsSinceEpoch));

    setState(() {
      orders.forEach((order) async {
        order.book = await ShopRequest().searchGoodByID(goodID: order.bookID);
      });
    });
  }

  // 刷新数据(用于下拉刷新)
  Future<void> refreshData() async {

      await Future.delayed(Duration(milliseconds: 50), () async {
        orders = await ShopRequest().getBuyerOrders();
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
        print(orders.length);
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
                  "没有查到订单\n\n去书店买一本吧!",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ) :
            // 如果有订单
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
                    mode: OrderMode.buyer,
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