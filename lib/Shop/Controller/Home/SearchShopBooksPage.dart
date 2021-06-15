import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart' show AsyncMemoizer;
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/Functions/Widgets/Anim_Search_Widget.dart';

// Models
import 'package:my_library/Shop/Model/ShopBookModel.dart';
import 'package:my_library/User/Model/UserModel.dart';

// Views
import 'package:my_library/Shop/View/Home/ShopHomeCell.dart';

// Packages
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Functions
import 'package:my_library/Shop/Function/ShopRequest.dart';



// 文本输入控制器
TextEditingController searchTextController = TextEditingController();

class SearchShopBooksPage extends StatefulWidget {

  String searchText = " ";

  SearchShopBooksPage({@required this.searchText = " "}) {
    if (this.searchText == "") {
      searchTextController.text = "";
    } else {
      searchTextController.text = this.searchText;
    }

  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchShopBooksPageState();
  }
}

class SearchShopBooksPageState extends State<SearchShopBooksPage> {
  
  List<ShopBookModel> books = [];

  ///定义异步寄存器, 用于FutureBuilder
  AsyncMemoizer _memoization = AsyncMemoizer<dynamic>();

  // 刷新数据(用于下拉刷新)
  Future<void> refreshData() async {
    // 拆分字符串,每个字符间都加上 %, 数据库可以进行模糊搜索
    List<String> chars = searchTextController.text.characters.toList();
    String sendText = "";
    chars.forEach((char) {
      sendText += char + "%";
    });
    books = await ShopRequest().searchGoodByName(goodName: sendText);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("搜索结果"),
        actions: [
          // 搜索按钮
          AnimSearchBar(
            this_toggle: 1,
            width: 280,
            textController: searchTextController,
            prefixIcon: Icon(Icons.search, color: Colors.black, size: 17,),
            suffixIcon: Icon(Icons.close, color: Colors.black, size: 20,),
            closeSearchOnSuffixTap: false,
            helpText: "查找二手书...",
            autoFocus: false,
            animationDurationInMilli: 250,
            searchAction: (value) {
              Utils.showToast("查找中...", context, mode: ToastMode.Loading, duration: 5);
              refreshData();
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

      body: FutureBuilder(
        // 加载只运行一次
          future: _memoization.runOnce(refreshData),
          builder: (context, snapshot) {
            if (books.length == 0) {
              return Container(
                child: Center(
                  child: Text("什么都没有找到...\n\n不如换个词试试?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),),
                ),
              );
            } else {
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
            }
          }),
    );
  }

}

/*

FutureBuilder(: _searchBooks()
        future,
        builder: (context, snapshot) {
          if (books.length == 0) {
            return Container(
              child: Center(
                child: Text("什么都没有找到...", style: TextStyle(fontSize: 20),),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                return BookListDetailCell(book: books[index]);
              },
            );
          }

        },
      ),



 */