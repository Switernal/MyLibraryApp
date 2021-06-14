// System
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_library/Functions/Network/Network.dart';
import 'package:my_library/MyBook/Controller/Book/BookInfoFormPage.dart';
import 'package:my_library/MyBook/Model/MyBookModel.dart';
import 'package:async/async.dart' show AsyncMemoizer;

// Controllers
import 'SearchMyBookPage.dart'; // 搜索页
import 'package:my_library/MyBook/View/BookShelf/BookShelfView.dart'; // 书架
// import 'package:my_library/Pages/BookInfoFormPage.dart'; // 添加书籍

// Packages
// import 'package:flutter_search_bar/flutter_search_bar.dart';
// import 'package:anim_search_bar/anim_search_bar.dart';


// Functions
import 'package:my_library/Functions/Utils/LocalStorageUtils.dart';
import 'package:my_library/Functions/Widgets/Anim_Search_Widget.dart';
import 'package:my_library/MyBook/Function/MyBookRequest.dart';
import 'package:my_library/Functions/Utils/Utils.dart';

// Models
import 'package:my_library/MyBook/Model/BookShelfModel.dart';


// 读到的ISBN码
String ISBN = "";

// 录入图书方式
enum AddBookWays {
  Scanner,
  Human
}


// TODO: MyLibrary App
class MyLibraryHomePage extends StatefulWidget {

  // 构造State
  @override
  State<StatefulWidget> createState() {
    return MyLibraryHomePageState();
  }
}

// TODO: MyLibrary App State状态
class MyLibraryHomePageState extends State<MyLibraryHomePage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  int buildCount = 0;
  int createCount = 0;

  /// Tabs
  List<Tab> tabs = [];

  /// 书架列表
  List<BookShelfModel> shelfs = [];

  /// 书架页面列表
  List<Widget> shelfPages = [];

  /// Tabbar 控制器
  TabController _mainTabController;

  /// 搜索组件 (废弃)
  //SearchBar searchBar;

  /// TexEditing控制器
  TextEditingController searchTextController = TextEditingController();

  /// 获取默认书架中书的数量
  int total = 0;

  /// 网络请求
  var request = MyBookRequest();

  ///定义异步寄存器, 用于FutureBuilder
  AsyncMemoizer _memoization = AsyncMemoizer<dynamic>();


  /// 创建书架页面[Local]
  /*
  Future<void> createBookShelfPages_local() async {

    // 藏书总数
    total = await LocalStorage.getTotalNumber_test();
    shelfs = await LocalStorage.getShelfs_test();

    tabs = [];
    shelfPages = [];

    for (var shelf in shelfs) {
      this.shelfPages.add(BookShelfView(shelf: shelf,));
      this.tabs.add(Tab(child: Container(padding: EdgeInsets.symmetric(horizontal: 10), child: Text(shelf.shelfName), ),));
    }

    // 初始化 TabBar 控制器
    _mainTabController = TabController(length: tabs.length, vsync: this);
  }

   */

  /// 创建书架页面(network))
  Future<void> createBookShelfPages_network() async {

    print("Home Create: " + (++createCount).toString());

    shelfs = [];
    tabs = [];
    shelfPages = [];

    // 请求初始化
    await request.init();

    // 藏书总数
    // 网络方法
    total = 0;

    shelfs = await MyBookRequest().getShelfs();
    // 依次获取藏书
    for (var shelf in shelfs) {
      shelf.books = await request.getBooksFromShelf(shelfName: shelf.shelfName);
    }

    List<MyBookModel> totalBooks = await request.getAllBooks();
    total = totalBooks.length;
    this.tabs.add(Tab(child: Container(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("所有藏书"), ),));
    this.shelfPages.add(BookShelfView(shelf: BookShelfModel(shelfName: "所有藏书", shelfID: -1, books: totalBooks),));

    for (var shelf in shelfs) {
      this.shelfPages.add(BookShelfView(shelf: shelf,));
      this.tabs.add(Tab(child: Container(padding: EdgeInsets.symmetric(horizontal: 10), child: Text(shelf.shelfName), ),));
    }

    // 初始化 TabBar 控制器
    _mainTabController = TabController(length: tabs.length, vsync: this);
  }


  // 专为 FutureBuilder 使用
  Future<void> futureForBuilder() async {
    await createBookShelfPages_network();
  }


  /// 页面Body[有书架时]
  Widget BodyArea_Over_2() {

    // print("BodyArea_Over_2");

    return TabBarView(
      controller: _mainTabController, // 指定控制器
      children: shelfPages,
      //mainTabsLabel.map((e) => Tab(text: e,)).toList(), // 页面组件
    );
  }

  Widget BodyArea_Only_1() {
    print("BodyArea_Only_1");

    if (total != 0) {
      if (shelfPages.isNotEmpty) {
        return shelfPages[0];
      }
    } else {
      return Container(
        padding: EdgeInsets.only(bottom: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Center(
              child: Text("好像一本书也没有...", style: TextStyle(fontSize: 20),),
            ),
            Padding(padding: EdgeInsets.all(10)),
            Center(
              child: Text("去添加一本吧!", style: TextStyle(fontSize: 20),),
            ),
            Padding(padding: EdgeInsets.all(10)),
            Center(
              child: Icon(Icons.arrow_downward, size: 50,),
            ),
          ],
        ),
      );
    }

  }

  Widget BodyArea_NotLogin() {
    return Container();
  }


  @override
  // TODO: State 初始化
  void initState() {
    super.initState();

  }

  @override 
  void dispose() {
    searchTextController = null;
    super.dispose();
    print("Home Page Dispose");
  }

  // TODO: 构建build方法
  @override
  Widget build(BuildContext context) {

    print("Home Build: " + (++buildCount).toString());


    // 这句话必须在build里写一次, 不然会出红色错误
    //_mainTabController = TabController(length: shelfs.length, vsync: this);

    return FutureBuilder(
      future: futureForBuilder(),//_memoization.runOnce(futureForBuilder),
      builder: (context, snapshot) {
        //print("Future Builder");

        return Scaffold(
          // TODO: 顶部bar
          appBar: AppBar(
            // 顶部title
            title: Text("我的藏书",textAlign: TextAlign.center,),
            centerTitle: true,
            // 打开抽屉按钮
            leading: IconButton(
              icon: Icon(Icons.dehaze),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            // 顶部导航栏
            bottom: tabs.length >= 2 ? TabBar(
                // 允许滑动
                isScrollable: true,
                // tabbar 控制器
                controller: _mainTabController,
                // 页面
                tabs: tabs//shelfs.map((e) => Tab(text: e.shelfName,)).toList(),
            ) : null,
            actions: [
              // 搜索按钮
              AnimSearchBar(
                width: 290,
                textController: searchTextController,
                prefixIcon: Icon(Icons.search, color: Colors.black, size: 17,),
                suffixIcon: Icon(Icons.close, color: Colors.black, size: 20,),
                closeSearchOnSuffixTap: true,
                helpText: "查找我的藏书...",
                autoFocus: false,
                animationDurationInMilli: 250,
                searchAction: (value) {
                  Utils.showToast("查找中...", context, mode: ToastMode.Loading);
                  searchTextController.clear();
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchMyBookPage(searchText: value,)));
                },
                onSuffixTap: () {
                  //setState(() {
                    searchTextController.clear();
                  //});
                },

              ),
              // 填充右侧空白
              Padding(
                padding: EdgeInsets.all(5),
                //child: Text(''),
              )
            ],
          ),
          //searchBar.build(context),


          // TODO: 页面主体
          body: (shelfPages.length < 2) ? BodyArea_Only_1() : BodyArea_Over_2(),

        );
      }
    );

  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}


