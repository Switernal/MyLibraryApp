import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:my_library/MyBook/Controller/BookShelf/BookShelfDetailPage.dart';
import 'package:my_library/MyBook/Controller/BookShelf/BookShelfEditPage.dart';

// Models
import 'package:my_library/MyBook/Model/BookShelfModel.dart';

// Functions
import 'package:my_library/Functions/Utils/Utils.dart';

// 书架管理界面的一个Cell
class BookShelfManageCell extends StatelessWidget {

  BookShelfModel shelf;

  dynamic deleteAction;

  dynamic editAction;

  BookShelfManageCell({Key key, this.shelf, this.deleteAction, this.editAction}) : super(key: key);

  Widget bodyArea() {
    return Container(
      // 只设定height, width自动适应
        height: 80,
        // 外边距
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        // 内边距
        padding: EdgeInsets.only(left: 20, right: 15, top: 20, bottom: 20),
        // 装饰
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.lightBlue, Colors.blue],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              spreadRadius: 4,
              color: Color.fromARGB(20, 0, 0, 0),
            ),
          ],
        ),
        // 并排组件
        child: Row(
          // 垂直方向在中心
          crossAxisAlignment: CrossAxisAlignment.center,
          // 两端对其
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // 宽度自适应
            Expanded(child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  this.shelf.shelfName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "数量: " + this.shelf.counts.toString() + " 本",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(200, 255, 255, 255),
                  ),
                ),
              ],
            ),),
            // 右侧箭头图标
            Padding(
              padding: EdgeInsets.only(left: 10, right: 0),
              child: Icon(
                Icons.chevron_right,
                color: Colors.white,
              ),
            )

          ],

        )
    );
  }

  // 长滑动菜单
  void slide_action(SlideActionType actionType, BuildContext context) {
    if (actionType == SlideActionType.secondary) {
      if (shelf.shelfName == "所有藏书") {
        Utils.showToast("这个不能删除", context);
      } else {
        deleteAction(shelf.shelfName);
      }
    } else {
      if (shelf.shelfName == "所有藏书") {
        Utils.showToast("这个不能编辑", context);
      } else {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
            BookShelfEditPage(
              shelfName: this.shelf.shelfName,
              mode: Mode.EditShelf,
              refreshBookShelf: editAction,
            )
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // 点击控件

    return GestureDetector(
      // 单击事件
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context)
           => BookShelfDetailPage(shelf: this.shelf,))),
      // Slidable做顶层控件,可以滑出菜单
      child: Slidable(
        // 使用Drawer滑动菜单风格
        actionPane: SlidableDrawerActionPane(),
        // 如果设置dismissal,必须设置key
        key: UniqueKey(),
        // 滑动删除动画
        dismissal: SlidableDismissal(
            child: SlidableDrawerDismissal(),
            onWillDismiss: (actionType) {
              slide_action(actionType, context);
            },
        ),

        actionExtentRatio: 0.25,

        // 包裹了一个Container,卡片控件
        child: bodyArea(),

        // 左侧菜单
        actions: [
          // 编辑按钮
          IconSlideAction(
            caption: '编辑',
            color: Colors.blue,
            icon: Icons.edit,
            onTap: () {
              if (shelf.shelfName == "所有藏书") {
                Utils.showToast("这个不能编辑", context);
              } else {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                    BookShelfEditPage(
                      shelfName: this.shelf.shelfName,
                      mode: Mode.EditShelf,
                      refreshBookShelf: editAction,
                    )
                )
                );
              }
            },
          ),

        ],
        // 右侧菜单
        secondaryActions: [
          IconSlideAction(
            caption: '删除',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {
              if (shelf.shelfName == "所有藏书") {
                Utils.showToast("这个不能删除", context);
              } else {
                deleteAction(shelf.shelfName);
              }
            },

          ),
        ],
      ),

      /*
      Container(
          height: 80,
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          padding: EdgeInsets.only(left: 20, right: 15, top: 20, bottom: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.lightBlue, Colors.blue],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                spreadRadius: 4,
                color: Color.fromARGB(20, 0, 0, 0),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    this.shelfData.shelfName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "数量: " + this.shelfData.numbersOfBooks.toString() + " 本",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(200, 255, 255, 255),
                    ),
                  ),
                ],
              ),),

              Padding(
                padding: EdgeInsets.only(left: 10, right: 0),
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
              )

            ],

          )
      ),

      */
    );
  }
}

// 书架信息
@deprecated
class BookShelfData {

  String shelfName;
  int numbersOfBooks;

  BookShelfData({this.shelfName, this.numbersOfBooks});

}
