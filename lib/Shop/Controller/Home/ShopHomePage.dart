import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart' show AsyncMemoizer;

// Models
import 'package:my_library/Shop/Model/ShopBookModel.dart';
import 'package:my_library/User/Model/UserModel.dart';

// Views
import 'package:my_library/Shop/View/Home/ShopHomeCell.dart';

// Packages
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Functions
import 'package:my_library/Shop/Function/ShopRequest.dart';


class ShopHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ShopHomePageState();
  }
}

class ShopHomePageState extends State<ShopHomePage> with AutomaticKeepAliveClientMixin {

/*
  List<ShopBookModel> books = [
    ShopBookModel(
      owner: UserModel(userName: "测试用户", phone: "13776155895"),
      createTime: DateTime(2021, 04, 09, 10, 10, 00),
      coverURL: "https://img3.doubanio.com/view/subject/l/public/s25948080.jpg",
      bookName: "云雀叫了一整天",
      appearance: 2,
      author: "木心",
      // translator: "陈丹青",
      price_origin: 30.00,
      price_now: 12.80,
      expressPrice: 12.21,
      press: "广西师范大学出版社",
      ISBN: "9787569377941",
      publicationDate: "2016-04",
      introduction: "《云雀叫了一整天》是由广西师范大学出版社出版的图书，作者是木心。该书由第一辑（诗歌）与第二辑（短句）组成，收入了《火车中的情诗》《女优的肖像》《伏尔加》等一百余首诗篇，逾百行木心式的精彩箴言。",
      //authorIntroduction: "木心（1927年2月14日—2011年12月21日），本名孙璞，字仰中，号牧心，笔名木心。中国当代作家、画家。1927年出生于浙江省嘉兴市桐乡乌镇东栅。毕业于上海美术专科学校。2011年12月21日3时逝世于故乡乌镇，享年84岁。",
    ),
  ];

 */

  List<ShopBookModel> books = [];

  ///定义异步寄存器, 用于FutureBuilder
  AsyncMemoizer _memoization = AsyncMemoizer<dynamic>();

  // 刷新数据(用于下拉刷新)
  Future<void> refreshData() async {
    books = await ShopRequest().getRandomGoods_20();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder(
      // 加载只运行一次
      future: _memoization.runOnce(refreshData),
      builder: (context, snapshot) {
        return Container(
          color: Colors.white10,
          child: RefreshIndicator(
            onRefresh: refreshData,
            child: StaggeredGridView.countBuilder(
              //controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              shrinkWrap: true,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              crossAxisCount: 4,
              itemCount: books.length,
              itemBuilder: (BuildContext context, int index) {
                return ShopHomeCell(book: books[index]);
              },
              staggeredTileBuilder: (index) => StaggeredTile.fit(2),

            ),
          ),
        );
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}