import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Controllers
import 'package:my_library/MyBook/Controller/BookShelf/BookShelfEditPage.dart';

// Views
import 'package:my_library/MyBook/View/BookShelf/BookShelfManageCell.dart';

// Functions
import 'package:my_library/Functions/Utils/LocalStorageUtils.dart';
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/MyBook/Function/MyBookRequest.dart';

// Models
import 'package:my_library/MyBook/Model/BookShelfModel.dart';

var BarEditButton = Icon(Icons.edit, color: Colors.white,);
bool isShowEditButton = false;
double rightPadding = 0.0;

class BookShelfManagePage extends StatefulWidget {

  dynamic refreshHomePage;

  BookShelfManagePage({this.refreshHomePage});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BookShelfManagePageState();
  }
}

class BookShelfManagePageState extends State<BookShelfManagePage> {

  // 书架名 : 书架
  Map<String, BookShelfModel> shelfs = {};

  /// 网络请求对象
  var request = MyBookRequest();

  /// 获取书架 (local)
  @deprecated
  Future<void> _getShelfs_Local() async {
    await LocalStorageUtils.getShelfs_test().then((result) {
      result.forEach((shelf) {
        shelfs[shelf.shelfName] = shelf;
      });

    });
  }

  /// 获取书架 (Network)
  Future<void> _getShelfs_Network() async {
    print("get shelfs");
    // 添加默认书架
    shelfs["所有藏书"] = BookShelfModel(shelfName: "所有藏书", shelfID: -1, books: await request.getAllBooks());
    // 初始化request
    await request.init();
    // 获取书架中图书数量
    var shelfCounts = await request.getBooksCountInShelf();
    // 获取书架
    await request.getShelfs().then((result) {
      result.forEach((shelf) {
        shelf.counts = shelfCounts[shelf.shelfName];
        shelfs[shelf.shelfName] = shelf;
      });
    });
  }

  /// 没有书架时的body
  Widget BodyArea_Empty() {
    // print("No Shelfs");
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 40, right: 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text("没有找到书柜...", style: TextStyle(fontSize: 20),),
          Padding(padding: EdgeInsets.all(10)),
          Text("去新建一个吧!", style: TextStyle(fontSize: 20),),
          Padding(padding: EdgeInsets.all(10)),
          Icon(Icons.subdirectory_arrow_right, size: 50,),
        ],
      ),
    );
  }

  Widget BodyArea_NotEmpty() {
    // print("Exist Shelfs");
    return ListView.builder(
      padding: EdgeInsets.only(top: 8),
      itemCount: shelfs.length,
      itemBuilder: (context, index) {
        String thisShelfName = shelfs.keys.toList()[index];

        return Row(
          children: [
            Expanded(
              child: BookShelfManageCell(
                shelf: shelfs[thisShelfName],
                // 传入删除操作
                deleteAction: (@required String shelfName) {
                  Utils.ShowAlertDialog(context: context,
                    title: "确定删除书架[${shelfName}]吗?",
                    content: "别担心，删除书架不会删除书架中的藏书，删除书架后您仍可以在[所有藏书]中查看您收藏在该书架中的图书",
                    Action1: () async {

                    // 删除存储 (Network)
                      var result = await request.deleteShelf(shelfName: shelfName);
                      switch (result) {
                        case 1:
                          Utils.showToast("删除成功", context, mode: ToastMode.Success);
                          break;
                        case 0:
                          Utils.showToast("删除失败", context, mode: ToastMode.Error);
                          break;
                        default:
                          Utils.showToast("发生未知错误", context, mode: ToastMode.Error);
                      }

                      setState(() {
                        shelfs.remove(shelfName);
                      });
                      Navigator.pop(context);
                      // 删除存储 (Local)
                      /*
                      LocalStorage.removeBookShelf(thisShelfName).then((result) {
                        if (result == false) {
                          Utils.showToast("默认书架不能删除喔", context);
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            shelfs.remove(thisShelfName);
                          });
                          Navigator.pop(context);
                        }
                      });

                       */
                    },
                    Action2: () => Navigator.pop(context),
                  );

                },
                // 传入修改操作
                editAction: (@required String newName) async {
                  if (!shelfs.containsKey(newName)) {

                    var oldName = thisShelfName;
                    Utils.showToast("更新中...", context, mode: ToastMode.Loading);

                    // 网络更新书架请求
                    var result = await request.updateShelf(oldShelfName: oldName, newShelfName: newName);
                    switch (result) {
                      case 1:
                        Utils.showToast("修改成功", context, mode: ToastMode.Success);
                        break;
                      case 0:
                        Utils.showToast("修改失败", context, mode: ToastMode.Error);
                        break;
                      default:
                        Utils.showToast("发生未知错误", context, mode: ToastMode.Error);
                    }

                    setState((){
                      // 修改对象,本地显示用
                      shelfs[newName] = shelfs[thisShelfName];
                      shelfs.remove(oldName);
                    });
                    return null;

                  } else {
                    return "书柜名已存在";
                  }
                },
              ),
            ),

          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("书架管理"),
      ),
      // 添加书柜按钮
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {

          Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
              BookShelfEditPage(
                  mode: Mode.AddShelf,
                  refreshBookShelf: (String newShelfName) async {

                    // 如果在书架列表总不存在新增书架的书架名, 调用新增书架操作
                      if (shelfs.containsKey(newShelfName) == false) {
                        // 新增书架数据 (network)
                        // Utils.showToast("正在添加...", context);

                        var result = await request.addShelf(newShelfName: newShelfName);
                        switch (result) {
                          case 1:
                            Utils.showToast("新增书架成功", context, mode: ToastMode.Success);
                            break;
                          case 0:
                            Utils.showToast("新增书架失败", context, mode: ToastMode.Error);
                            break;
                          default:
                            Utils.showToast("发生未知错误", context, mode: ToastMode.Error);
                        }

                        // 更新数据 (local)
                        /*
                          LocalStorage.addNewShelf_test(newShelfName);
                           */
                        setState(() {
                          // 添加新书架, 用于界面显示
                          shelfs[newShelfName] = new BookShelfModel(shelfName: newShelfName);
                        });

                        // 刷新主页的书柜信息
                        widget.refreshHomePage();

                        return null;
                      } else {
                        return "书柜名已存在";
                    }
                  },

              )));
        },
      ),
      body: FutureBuilder(
        future: _getShelfs_Network(),
        builder: (context, snapshot) {
          return (shelfs.length == 0) ? BodyArea_Empty() : BodyArea_NotEmpty();
        },
      ),

          /*
      Row(
        children: [
          Expanded(child: BookShelfManageCell(
            shelfData: BookShelfData(
                shelfName: "书房",
                numbersOfBooks: 200
            ),
          ),)
        ],
      )
      */

    );
  }
}