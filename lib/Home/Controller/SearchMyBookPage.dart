import 'package:flutter/material.dart';
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/Functions/Widgets/Anim_Search_Widget.dart';

// Packages
import 'package:my_library/MyBook/Function/MyBookRequest.dart';

// Models
import 'package:my_library/MyBook/Model/MyBookModel.dart';
import 'package:my_library/MyBook/View/BookShelf/BookListDetailCell.dart';


class SearchMyBookPage extends StatefulWidget  {

  /// 查询文本
  /// 如果默认串为""的话,查询SQL语句会出现%%的情况,应该会查询结果为全部图书
  /// 设为两个空格可以解决这个问题
  String searchText = "  ";

  SearchMyBookPage({@required this.searchText});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchMyBookPageState();
  }
}

class SearchMyBookPageState extends State<SearchMyBookPage> {

  /// 网络请求
  var request = MyBookRequest();

  /// 文本输入控制器
  TextEditingController searchTextController = TextEditingController();

  /// 查询结果
  List<MyBookModel> books = [];

  /// 预加载函数,查询书籍
  Future<void> _searchBooks() async {
    // 初始化网络请求对象
    await request.init();
    // 拆分字符串,每个字符间都加上 %, 数据库可以进行模糊搜索
    List<String> chars = searchTextController.text.characters.toList();
    String sendText = "";
    chars.forEach((char) {
      sendText += char + "%";
    });
    // 查询书籍
    books = await request.getBooksByName(bookName: sendText);
  }

  @override
  void initState() {
    super.initState();
    // 设置搜索框文字
    searchTextController.text = widget.searchText;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // searchTextController = null;
    super.dispose();
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
            width: 290,
            textController: searchTextController,
            prefixIcon: Icon(Icons.search, color: Colors.black, size: 17,),
            suffixIcon: Icon(Icons.close, color: Colors.black, size: 20,),
            closeSearchOnSuffixTap: false,
            helpText: "查找书籍...",
            autoFocus: false,
            animationDurationInMilli: 250,
            this_toggle: 1,
            searchAction: (inputText) {
              Utils.showToast("查找中...", context, mode: ToastMode.Loading);
              setState(() {
                searchTextController.text = inputText;
              });
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
        future: _searchBooks(),
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
    );
  }
}