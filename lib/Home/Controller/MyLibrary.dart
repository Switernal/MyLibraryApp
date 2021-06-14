// System
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_library/Functions/Network/Network.dart';
import 'package:my_library/MyBook/Controller/Book/BookInfoFormPage.dart';
import 'package:my_library/main.dart';

// Pages
import 'package:my_library/Home/Controller/MyLibraryHomePage.dart';
import 'package:my_library/Drawer/DrawerPage.dart';  // 抽屉
import 'package:my_library/Shop/Controller/Book/PublishBookPage.dart';
import 'package:my_library/Shop/Model/ShopBookModel.dart';
import 'package:my_library/User/Model/UserModel.dart';
import 'ScannerPage.dart';

// Packages
import 'package:ai_barcode/ai_barcode.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:my_library/Shop/Controller/Home/ShopPage.dart';
import 'package:permission_handler/permission_handler.dart';

// Functions
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/Functions/Utils/LocalStorageUtils.dart';
import 'package:my_library/Functions/Widgets/Anim_Search_Widget.dart';
import 'package:my_library/MyBook/Function/SearchBookByISBN.dart';


// Models


// 读到的ISBN码
String ISBN = "";

// 录入图书方式
enum AddBookWays {
  Scanner,
  Human,
  ISBN
}

// Tabbar 控制器
TabController _mainTabController;

class MyLibrary extends StatefulWidget {

  // 如果从入口页直接过来, 退出登录时需要refresh页面
  dynamic logoutRefreshState;

  MyLibrary({@required this.logoutRefreshState});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyLibraryState();
  }
}

class MyLibraryState extends State<MyLibrary> {

  //当前显示页面的
  int currentIndex = 0;

  //点击导航项要显示的页面
  var bottomPages = [MyLibraryHomePage(), ShopPage()];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 是否显示选择服务器弹窗
      bool isShowDialog = true;
      // Debug模式下允许选择服务器
      if (kDebugMode && isShowDialog) {

        List<Widget> allServerOptions = [];

        Network().servers.forEach((serverURL) {
          // 添加选项
          allServerOptions.add(
              SimpleDialogOption(
                child: Text(serverURL),
                onPressed: () {
                  Network().currentServer = serverURL;
                  Navigator.pop(context);
                },
              )
          );
          // 分割线
          allServerOptions.add(Divider());
        });

        showDialog(context: context,
            builder: (context) {
              return SimpleDialog(
                title: Text("选择服务器"),
                children: allServerOptions,
              );
            }
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: bottomPages,
      ),
      //body: bottomPages[currentIndex],

      // TODO: 左侧抽屉
      drawer: MainDrawer(
            refreshHomePage: () {setState(() {print("refersh");});},
            refreshApp: widget.logoutRefreshState,
          ), // 创建一个新的抽屉对象

      // TODO: 底部导航栏(不规则)
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          children: <Widget>[
            buildBotomItem(currentIndex, 0, Icons.menu_book, "我的藏书"),
            buildBotomItem(currentIndex, 1, Icons.store_mall_directory, "二手书店"),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceAround,
        ),

      ),

      // TODO: 中间浮动按钮
      // 如果当前页面为1, 为二手书店, 则按钮动作为新增页面
      // 如果当前页面为0, 为个人藏书状态, 按钮动作为新增藏书
      floatingActionButton:
          // 如果index = 1, 为商店模式
      currentIndex == 1 ?
          // 商店模式
      FloatingActionButton(
          child: PopupMenuButton<AddBookWays>(
            icon: Icon(Icons.add),
            tooltip: "发布二手书, 仅支持通过ISBN转售",
            itemBuilder: (BuildContext context) => <PopupMenuEntry<AddBookWays>>[
                const PopupMenuItem<AddBookWays>(
                  value: AddBookWays.Scanner,
                  child: Text("扫描条码"),
                ),
                const PopupMenuItem<AddBookWays>(
                  value: AddBookWays.ISBN,
                  child: Text('输入ISBN'),
                ),
            ],
            onSelected: (AddBookWays result) async {
              if (result == AddBookWays.Scanner) {
                // 扫描条码
                TargetPlatform platform = Theme.of(context).platform;
                if (TargetPlatform.iOS == platform) {
                  ISBN = await Utils.scanBarcode_iOS(mounted: mounted);
                  // "-1"代表取消
                  if (ISBN != "-1") {
                    await SearchBookByISBN.addShopBook(ISBN: ISBN, context: context);
                  }
                }

                if (TargetPlatform.android == platform) {
                  ISBN = await Utils.scanBarcode_Android(context: context);
                  await SearchBookByISBN.addShopBook(ISBN: ISBN, context: context);
                }
              }

              if (result == AddBookWays.ISBN) {
                // await SearchBookByISBN.addShopBook(ISBN: ISBN, context: context);
                var controller = TextEditingController();
                controller.text = ""; //"9787569377941";
                // 手动录入
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("通过图书的ISBN号发布二手书"),
                        content: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: "请输入图书的13或10位ISBN号",
                          ),
                        ),
                        actions: [
                          TextButton(
                              child: Text("确定",),
                              onPressed: () async {
                                await SearchBookByISBN.addShopBook(ISBN: controller.text, context: context);
                                //Navigator.pop(context);
                              }),
                          TextButton(onPressed: () => Navigator.pop(context), child: Text("取消")),
                        ],
                      );
                    }
                );
                /*
                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                    PublishBookPage(
                        bookToPublish: ShopBookModel(
                          bookID: 1,
                          userID: 1,
                          owner: UserModel(userName: "Aunt"),
                          createTime: DateTime.now(),
                          coverURL: "https://img3.doubanio.com/view/subject/l/public/s25948080.jpg",//"https://www.hualigs.cn/image/60bcfe294addc.jpg",
                          author: "木心",
                          bookName: "云雀叫了一整天",
                          ISBN: "1234567890",
                          price_origin: 30.0,
                          press: "广西师范大学出版社"
                        ),
                        publishMode: PublishMode.add)
                ));

                 */
              }
            },
          ),
          heroTag: "PublishBook",
          onPressed: () {
            print("发布二手书");
          }
      ) :
          // 个人藏书模式
      FloatingActionButton(
        child: PopupMenuButton<AddBookWays>(
          onSelected: (AddBookWays result) {
            setState(() async {
              print(result);
              if (result == AddBookWays.Scanner) {
                // 扫描条码

                // iOS扫码
                TargetPlatform platform = Theme.of(context).platform;
                if (TargetPlatform.iOS == platform) {
                  ISBN = await Utils.scanBarcode_iOS(mounted: mounted);
                  // "-1"代表取消
                  if (ISBN != "-1") {
                    SearchBookByISBN.addMyBook(ISBN: ISBN, context: context);
                  }
                }

                // 安卓扫码
                if (TargetPlatform.android == platform) {
                  ISBN = await Utils.scanBarcode_Android(context: context);
                  SearchBookByISBN.addMyBook(ISBN: ISBN, context: context);
                }
              }
              if (result == AddBookWays.Human) {
                // 手动录入
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                  return BookInfoFormPage.addfromHuman();
                }));
              }
              if (result == AddBookWays.ISBN) {
                var controller = TextEditingController();
                controller.text = ""; //"9787569377941";
                // 手动录入
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("通过ISBN号搜索图书"),
                        content: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: "请输入图书的13或10位ISBN码",
                          ),
                        ),
                        actions: [
                          TextButton(
                              child: Text("确定",),
                              onPressed: () async {
                                await SearchBookByISBN.addMyBook(ISBN: controller.text, context: context);
                                Navigator.pop(context);
                              }),
                          TextButton(onPressed: () => Navigator.pop(context), child: Text("取消")),
                        ],
                      );
                    }
                );
              }
            });
          },

          icon: Icon(Icons.add),
          tooltip: "新增藏书",
          itemBuilder: (BuildContext context) => <PopupMenuEntry<AddBookWays>>[
            const PopupMenuItem<AddBookWays>(
              value: AddBookWays.Scanner,
              child: Text("扫描条码"),
            ),
            const PopupMenuItem<AddBookWays>(
              value: AddBookWays.Human,
              child: Text('手动录入'),
            ),
            const PopupMenuItem<AddBookWays>(
              value: AddBookWays.ISBN,
              child: Text('搜索ISBN'),
            ),
          ],
        ),
        /*
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => BookInfoFormPage()));
        },
         */
        tooltip: '新增藏书',
        //child: Icon(Icons.add),
      ),

      // TODO: 浮动按钮位置
      floatingActionButtonLocation: currentIndex == 0 ?
      FloatingActionButtonLocation.centerDocked :
      FloatingActionButtonLocation.centerDocked,
    );
  }


  /*
  /// ai_barcode 扫描
  Future<String> scanBarcodeNormal_Android() async {
    var result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => ScannerPage()));
    setState(() {
      ISBN = result;
    });
  }

  // TODO: 扫描条码的动作[安卓有问题]
  Future<void> scanBarcodeNormal_iOS() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // 返回给ISBN字符串
    setState(() {
      ISBN = barcodeScanRes;
    });
  }

   */





  // TODO: 构建新的底部导航按钮
  /**
   * @param [selectIndex] 当前选中的页面
   * @param [index] 每个条目对应的角标
   * @param [iconData] 每个条目对就的图标
   * @param [title] 每个条目对应的标题
   */
  buildBotomItem(int selectIndex, int index, IconData iconData, String title) {
    //未选中状态的样式
    TextStyle textStyle = TextStyle(fontSize: 12.0,color: Colors.grey);
    MaterialColor iconColor = Colors.grey;
    double iconSize=20;
    EdgeInsetsGeometry padding =  EdgeInsets.only(top: 8.0);

    if(selectIndex==index){
      //选中状态的文字样式
      textStyle = TextStyle(fontSize: 13.0,color: Colors.blue);
      //选中状态的按钮样式
      iconColor = Colors.blue;
      iconSize=25;
      padding =  EdgeInsets.only(top: 6.0);
    }
    Widget padItem = SizedBox();
    if (iconData != null) {
      padItem = Padding(
        padding: padding,
        child: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              children: <Widget>[
                Icon(
                  iconData,
                  color: iconColor,
                  size: iconSize,
                ),
                Text(
                  title,
                  style: textStyle,
                )
              ],
            ),
          ),
        ),
      );
    }
    Widget item = Expanded(
      flex: 1,
      child: new GestureDetector(
        onTap: () {
          if (index != currentIndex) {
            setState(() {
              currentIndex = index;
            });
          }
        },
        child: SizedBox(
          height: 52,
          child: padItem,
        ),
      ),
    );
    return item;
  }
}