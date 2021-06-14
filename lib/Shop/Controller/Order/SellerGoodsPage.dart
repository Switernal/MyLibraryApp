import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart' show AsyncMemoizer;
import 'package:my_library/Shop/Function/ShopRequest.dart';

// Models
import 'package:my_library/Shop/Model/ShopBookModel.dart';

// Views
import 'package:my_library/Shop/View/Home/ShopHomeCell.dart';

// Packages
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:my_library/Shop/View/Order/GoodListCell.dart';

class SellerGoodsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SellerGoodsPageState();
  }
}

class SellerGoodsPageState extends State<SellerGoodsPage> with AutomaticKeepAliveClientMixin {

  List<ShopBookModel> books = [];

  ///定义异步寄存器, 用于FutureBuilder
  AsyncMemoizer _memoization = AsyncMemoizer<dynamic>();

  // 刷新数据(用于下拉刷新)
  Future<void> loadData() async {
    books = await ShopRequest().getSellerGoods();
    // 已售出的商品不显示
    books.removeWhere((book) => book.isSoldOut == true);
    // 按时间倒序排序
    books.sort((book1, book2) => book2.createTime.millisecondsSinceEpoch.compareTo(book1.createTime.millisecondsSinceEpoch));
  }

  // 刷新数据(用于下拉刷新)
  Future<void> refreshData() async {
    books = await ShopRequest().getSellerGoods();
    // 已售出的商品不显示
    books.removeWhere((book) => book.isSoldOut == true);
    setState(() {
      books.sort((book1, book2) => book2.createTime.millisecondsSinceEpoch.compareTo(book1.createTime.millisecondsSinceEpoch));
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder(
      future: _memoization.runOnce(loadData),
      builder: (context, snapshot) {
        return books.isEmpty ?
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
              width: double.infinity,
              padding: EdgeInsets.only(bottom: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "你还没有发布过二手书\n\n去添加一本吧!",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    Padding(padding: EdgeInsets.all(10),),
                    Icon(Icons.arrow_downward, size: 30,),
                  ],
                )
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
                itemCount: books.length,
                itemBuilder: (context, row) {
                  return GoodListCell(book: books[row], refreshGoodsList: refreshData,);
                }
            ),

          ),
        );
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}