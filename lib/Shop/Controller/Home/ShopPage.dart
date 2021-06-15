import 'package:flutter/material.dart';
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/Shop/Controller/Home/SearchShopBooksPage.dart';
import 'package:my_library/Shop/Controller/Order/SellerGoodsPage.dart';
import 'package:my_library/Shop/Controller/Order/SellerOrdersPage.dart';

import 'package:my_library/Functions/Widgets/Anim_Search_Widget.dart';

// Controllers
import 'package:my_library/Home/Controller/SearchMyBookPage.dart';
import 'package:my_library/Shop/Controller/Home/ShopHomePage.dart';
import '../Order/BuyerOrdersPage.dart';
import '../Order/SellerOrdersPage.dart';

// Views
import 'package:my_library/Shop/View/Home/ShopHomeCell.dart';

// Packages
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';


// 文本输入控制器
TextEditingController searchTextController = TextEditingController();

class ShopPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ShopPageState();
  }
}

class ShopPageState extends State<ShopPage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  /// 滚动监视器
  ScrollController _scrollController = new ScrollController();

  /// Tab控制器
  TabController _tabController;

  /// 页面
  List<Widget> Pages = [ShopHomePage(), SellerGoodsPage(), SellerOrdersPage(), BuyerOrdersPage()];


  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: Pages.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar:
        AppBar(
          title: Text("二手书店"),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: "书店", icon: Icon(Icons.home),),
              Tab(text: "我发布的", icon: Icon(Icons.publish),),
              Tab(text: "我卖出的", icon: Icon(Icons.attach_money),),
              Tab(text: "我买到的", icon: Icon(Icons.inventory),), // Icons.inventory
            ],
          ),
          // 打开抽屉按钮
          leading: IconButton(
            icon: Icon(Icons.dehaze),
            onPressed: () => Scaffold.of(context).openDrawer(),

          ),

          actions: [
            // 搜索按钮
            AnimSearchBar(
              width: 300,
              textController: searchTextController,
              prefixIcon: Icon(Icons.search, color: Colors.black, size: 17,),
              suffixIcon: Icon(Icons.close, color: Colors.black, size: 20,),
              closeSearchOnSuffixTap: true,
              helpText: "查找二手书...",
              autoFocus: false,
              animationDurationInMilli: 250,
              searchAction: (value) {
                Utils.showToast("查找中...", context, mode: ToastMode.Loading, duration: 5);
                searchTextController.clear();
                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                    SearchShopBooksPage(searchText: value,)
                ));
              },
              onSuffixTap: () {
                setState(() {
                  searchTextController.clear();
                });
              },

            ),
            // 填充右侧空白
            Padding(
              padding: EdgeInsets.all(5),
              child: Text(''),
            )
          ],
        ),



        // 浮动按钮: 购物车
      /*
        floatingActionButton: FloatingActionButton(
          heroTag: "ShoppingCart",
          tooltip: "我的订单",
          child: Icon(Icons.assignment_outlined),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ShoppingCartPage()));
          },
        ),

       */

        body: TabBarView(
          controller: _tabController,
          children: Pages,
        ),

      // StaggeredGridView 官方样例
      // body: StaggeredGridView.countBuilder(
      //   crossAxisCount: 4,
      //   itemCount: 8,
      //   itemBuilder: (BuildContext context, int index) => new Container(
      //       color: Colors.green,
      //       child: new Center(
      //         child: new CircleAvatar(
      //           backgroundColor: Colors.white,
      //           child: new Text('$index'),
      //         ),
      //       )),
      //   staggeredTileBuilder: (int index) =>
      //   new StaggeredTile.count(2, 2),
      //   mainAxisSpacing: 4.0,
      //   crossAxisSpacing: 4.0,
      // ),

        // 系统自带GridView, 无法动态调整Cell大小, 只能按规定比例定义
        // body: GridView.builder(
        //   shrinkWrap: true,
        //   itemCount: 9,
        //   //physics: NeverScrollableScrollPhysics(),
        //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //     crossAxisCount: 2,
        //     mainAxisSpacing: 5,
        //     crossAxisSpacing: 5,
        //     childAspectRatio: 0.7,
        //   ),
        //   itemBuilder: (context, index) {
        //     return ShopHomeCell();
        //   },
        // ),

    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}