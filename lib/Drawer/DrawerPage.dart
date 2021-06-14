import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_library/Functions/Network/Network.dart';

// Pages
import 'package:my_library/User/Controller/UserLoginPage.dart';
import 'package:my_library/MyBook/Controller/BookShelf/BookShelfManagePage.dart';
import 'package:my_library/MyBook/Controller/Statistics/BookStatisticsPage.dart';
import 'package:my_library/Drawer/(Deprecated)MyOrdersPage.dart';
import 'package:my_library/User/Controller/UserHomePage.dart';

// Package
import 'package:my_library/Functions/Utils/LocalStorageUtils.dart';
import 'package:my_library/User/Controller/UserSignUpPage.dart';
import 'package:my_library/User/Function/UserRequest.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:extended_image/extended_image.dart';
import 'package:my_library/Functions/Widgets/WebviewPage.dart';

// Functions
import 'package:my_library/User/Model/UserModel.dart';
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

bool isLogin = false;
String userName = "点击此处登录";
String userDescription = "登录后使用更多功能";

// 主界面Drawer
class MainDrawer extends StatefulWidget {

  // 刷新首页
  dynamic refreshHomePage;
  // 刷新app(退出登录用)
  dynamic refreshApp;

  MainDrawer({this.refreshHomePage, this.refreshApp});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MainDrawerState();
  }
}

// Drawer的State
class MainDrawerState extends State<MainDrawer> {

  static String webURL = "https://mylibrary.switernal.com";

  /// 通过浏览器打开外部URL(异步)
  void launchWebsite({String route = ""}) async {
    var _url = webURL + route;
    await canLaunch(_url) ? await launch(_url) : throw '无法打开链接';
  }

  /// 刷新Drawer的登录状态
  Future<void> refreshLoginStatus() async {
      await LocalStorageUtils.isLogin().then((value) {

        isLogin = value;
        if (value == true) {
          LocalStorageUtils.getUserName_Local().then((value) => userName = "欢迎回来，" + value + " ！");
          LocalStorageUtils.getUserEmail_Local().then((value) => userDescription = value);
        } else {
          userName = "点击此处登录";
          userDescription = "登录后使用更多功能";
        }
      });
  }


  /// DrawerState的 initState
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // print("Drawer initState!");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print("Drawer Dispose");
  }



  /// build方法
  @override
  Widget build(BuildContext context) {

    print("Drawer Build");

    // Drawer主体
    return Drawer(
      // 脚手架
      child: Scaffold(
        // 顶部栏
        appBar: AppBar(
          elevation: 0,// 隐藏阴影
          automaticallyImplyLeading: false, // 隐藏左侧按钮
        ),
        /// 底部导航,用于退出登录[如果isLogin == true,则显示,否则返回null不显示]
        bottomNavigationBar: FutureBuilder(
          future: refreshLoginStatus(),
          builder: (context, snapshot) {
            // print("Drawer: isLogin : " + isLogin.toString());
            return isLogin ?
            BottomNavigationBar(
              //fixedColor: Colors.grey,
              selectedItemColor: Colors.black54,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              currentIndex: 0,
              items: [
                BottomNavigationBarItem(label: "修改个人信息", icon: Icon(Icons.edit)),
                BottomNavigationBarItem(label: "退出登录", icon: Icon(Icons.logout)),
              ],
              onTap: (selected) async {
                // 点击修改个人信息按钮
                if (selected == 0) {
                  var userID = await LocalStorageUtils.getUserID_Local();
                  var nowUser = await UserRequest().getUserByID(userID);
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      UserSignUpPage(mode: UserMode.edit, nowUser: nowUser,)
                  ));
                }
                // 点击退出登录按钮
                if (selected == 1) {
                  setState(() {
                    UserModel.setUserLogoutStatus();
                    refreshLoginStatus();
                    if (widget.refreshApp != null) {
                      widget.refreshApp();
                      Navigator.pop(context);

                    } else {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  });
                }
              },
            ) : Container(height: 0, width: 0,);
          },
        ),
        /// Drawer的body
        body: ListView(
          children: <Widget>[
            /// 用户信息,异步Widget,等待获取登录状态后再加载
            FutureBuilder(
                future: refreshLoginStatus(),
                builder: (context, snapshot) {
                  return UserAccountsDrawerHeader(
                    accountName: Text(userName),
                    accountEmail: Text(userDescription),
                    currentAccountPicture: CircleAvatar(
                      //backgroundImage: AssetImage('assets/images/txr.jpg'),
                      child: Icon(
                        Icons.person,
                        size: 40,
                      ),
                    ),
                    arrowColor: Colors.transparent, // 右侧三角设为透明色
                    /// 点击用户名事件
                    onDetailsPressed: () {
                      UserModel.getUserLoginStatus().then((value) {
                        // 如果已登录,则转跳用户个人空间
                        if (value == true) {
                          /// TODO: 个人空间暂未开发
                          /*
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>
                              UserHomePage()));

                           */
                        } else {
                          // 如果未登录,则转跳登录界面
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>
                              UserLoginPage(
                                refresher: () {
                                  setState(() {
                                    refreshLoginStatus();
                                  });
                                },
                              )));
                        }
                      });
                    },
                  );
            }),

            /// 书架管理菜单
            ListTile(
              title: Text('书架管理'),
              subtitle: Text('更好地管理你的书架',maxLines: 2,overflow: TextOverflow.ellipsis,),
              leading: Icon(Icons.amp_stories, color: Colors.blue, size: 30,),// CircleAvatar(child: Text("1")),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => BookShelfManagePage(refreshHomePage: widget.refreshHomePage,)));
              },
            ),


            // 分割线
            Divider(),

            /// 书架管理菜单
            ListTile(
              enabled: false,
              title: Text('书籍统计'),
              subtitle: Text('查看你的藏书数据',maxLines: 2,overflow: TextOverflow.ellipsis,),
              leading: Icon(Icons.bar_chart, color: Colors.blue, size: 30,),// CircleAvatar(child: Text("2")),
              onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => BookStatisticPage()));},
            ),

            //分割线
            Divider(),

            /// 我的订单菜单 (现已合并入二手书店)
            /*
            ListTile(
              title: Text('我的订单'),
              subtitle: Text('查询你的二手书订单',maxLines: 2,overflow: TextOverflow.ellipsis,),
              leading: Icon(Icons.assignment_outlined, color: Colors.blue, size: 30,),// CircleAvatar(child: Text("3")),
              onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => MyOrdersPage()));},
            ),

            //分割线
            Divider(),

             */

            /// 我的订单菜单
            ListTile(
              title: Text('清除缓存'),
              subtitle: Text('清除本地图书封面缓存',maxLines: 1,overflow: TextOverflow.ellipsis,),
              leading: Icon(Icons.cached, color: Colors.blue, size: 30,),// CircleAvatar(child: Text("3")),
              onTap: (){
                clearDiskCachedImages().then((bool result) => Utils.showToast("缓存清除成功", context, mode: ToastMode.Success));
              },
            ),

            //分割线
            Divider(),


            /// Debug模式下允许选择服务器
            //kDebugMode ? Column(
            Column(
              children: [
                ListTile(
                  title: Text('选择服务器'),
                  subtitle: Text('当前服务器: ${Network().currentServer}',maxLines: 3,overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10),),
                  leading: Icon(Icons.cloud_outlined, color: Colors.blue, size: 30,),// CircleAvatar(child: Text("3")),
                  onTap: (){

                      List<Widget> allServerOptions = [];

                      Network().servers.forEach((serverURL) {
                        // 添加选项
                        allServerOptions.add(
                            SimpleDialogOption(
                              child: Text(serverURL),
                              onPressed: () {
                                setState(() {
                                  Network().currentServer = serverURL;
                                });

                                Utils.showToast("服务器切换成功", context, mode: ToastMode.Success);
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

                  },
                ),

                Divider(),
              ],
            ),



            /// 关于菜单
            new AboutListTile(
              icon: Icon(Icons.info_outline, color: Colors.blue, size: 30,), //new CircleAvatar(child: Text("4")),
              child: new Text("关于"),
              applicationName: "一千零一夜",
              applicationVersion: "Java课程设计",
              applicationIcon: Image.asset(
                  'assets/images/icon.png',
                  width: 55.0,
                  height: 55.0,
                ),
              // Icon(Icons.menu_book_outlined, size: 55.0, color: Colors.blue,),
              //new Image.asset(
              //   'assets/images/txr.jpg',
              //   width: 55.0,
              //   height: 55.0,
              // ),
              //applicationLegalese: "个人图书管理&二手书交易",
              aboutBoxChildren: <Widget>[

                ListTile(
                  title: Text('开发者'),
                  subtitle: Text('李清昀 201983290048\n朱梓源 201983290041',maxLines: 2,overflow: TextOverflow.ellipsis,),
                  leading: Icon(Icons.person, color: Colors.blue, size: 30,),// CircleAvatar(child: Text("1")),
                  onTap: (){showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // return object of type Dialog
                      return AlertDialog(
                        title: new Text('开发者信息'),
                        content: new Text("南京信息工程大学\n计算机与软件学院\n\n19计科1班 李清昀 201983290048\n19计科2班 朱梓源 201983290041"),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text("好"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );;},
                ),


                ListTile(
                  title: Text('版本'),
                  subtitle: Text(Utils.Version,maxLines: 2,overflow: TextOverflow.ellipsis,),
                  leading: Icon(Icons.assessment_outlined, color: Colors.green, size: 30,),// CircleAvatar(child: Text("1")),
                  onTap: (){ //Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // return object of type Dialog
                        return AlertDialog(
                          title: new Text('当前版本'),
                          content: new Text(Utils.Version),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text("好"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),



                ListTile(
                  title: Text('查看更新记录'),
                  subtitle: Text("上次更新: " + Utils.UpdateDate,maxLines: 2,overflow: TextOverflow.ellipsis,),
                  leading: Icon(Icons.date_range, color: Colors.orange, size: 30,),// CircleAvatar(child: Text("1")),
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder:
                    (context) => WebViewPage(title: "更新记录", url: webURL + "/update.html")
                    ));
                    /*
                    showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // return object of type Dialog
                      return AlertDialog(
                        title: new Text('更新记录'),
                        content: RichText(
                            text: TextSpan(text: '项目创建日期 : 2021.04.09\n', style: TextStyle(color: Colors.black, fontSize: 13),
                                children: <TextSpan>[
                                  TextSpan(text: '0.1 Alpha 1 ', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                                  TextSpan(text: ": 2021.04.23\n"),
                                  TextSpan(text: '0.1 Alpha 2 ', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                                  TextSpan(text: ": 2021.05.21\n"),
                                  TextSpan(text: '0.1 Alpha 3 ', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                                  TextSpan(text: ": 2021.06.05\n"),
                                ]
                            )
                        ),

                        actions: <Widget>[
                          new FlatButton(
                            child: new Text("好"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                    */
                    },
                ),

                ListTile(
                  title: Text('简介'),
                  subtitle: Text('个人图书管理与二手书交易',maxLines: 2,overflow: TextOverflow.ellipsis,),
                  leading: Icon(Icons.assistant_photo_sharp, color: Colors.purple, size: 30,),// CircleAvatar(child: Text("1")),
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder:
                        (context) => WebViewPage(title: "简介", url: webURL + "/about.html")
                    ));
                    /*
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // return object of type Dialog
                        return AlertDialog(
                          title: new Text('App 功能'),
                          content: new Text("个人图书管理和二手书交易平台, 轻松管理您的私人书藏"),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text("好"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );

                     */
                  },
                ),

                ListTile(
                  title: Text('检查更新'),
                  subtitle: Text('获取更新信息',maxLines: 2,overflow: TextOverflow.ellipsis,),
                  leading: Icon(Icons.cloud_upload, color: Colors.deepOrange, size: 30,),// CircleAvatar(child: Text("1")),
                  onTap: () {
                    launchWebsite(route: "/download.html");
                    /*
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {

                      // return object of type Dialog

                        return AlertDialog(
                          title: new Text('已是最新版本!'),
                          content: new Text("当前版本: " + Utils.Version),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text("好"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );

                    },
                  );
                  */
                  },
                ),

                ListTile(
                  title: Text('致谢'),
                  subtitle: Text('感谢所有的贡献者',maxLines: 2,overflow: TextOverflow.ellipsis,),
                  leading: Icon(Icons.people, color: Colors.blue, size: 30,),// CircleAvatar(child: Text("1")),
                  onTap: (){showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // return object of type Dialog
                      return AlertDialog(
                        title: Text('贡献人员名单'),
                        content: Text(
                                "江湖骗子\n" +
                                "GJ\n" +
                                "叉叉\n" +
                                "和宋\n" +
                                "sbw\n" +
                                "三三\n"
                        ),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text("好"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );;},
                ),

                ListTile(
                  title: Text('官方网站'),
                  subtitle: Text('mylibrary.switernal.com',maxLines: 2,overflow: TextOverflow.ellipsis,),
                  leading: Icon(Icons.open_in_browser, color: Colors.black54, size: 30,),// CircleAvatar(child: Text("1")),
                  onTap: (){
                    // 打开URL
                    launchWebsite();
                  },
                ),

              ],
            ),
            Divider(),//分割线
          ],
        ),
      ),
    );
  }
}

/*
     ListTile(
              title: Text('ListTile1'),
              subtitle: Text('ListSubtitle1',maxLines: 2,overflow: TextOverflow.ellipsis,),
              leading: CircleAvatar(child: Text("1")),
              onTap: (){Navigator.pop(context);},
            ),
* */