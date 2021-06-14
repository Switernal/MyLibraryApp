import 'dart:ui';

import 'package:date_format/date_format.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart' show AsyncMemoizer;

// Functions
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/Shop/Controller/Book/ShopBookDetailPage.dart';
import 'package:my_library/Shop/Function/ShopRequest.dart';
import 'package:my_library/User/Function/UserRequest.dart';

// Models
import 'package:my_library/Shop/Model/OrderModel.dart';
import 'package:my_library/Shop/Model/ShopBookModel.dart';

// Pages
import 'package:my_library/Functions/Widgets/WebviewPage.dart';


enum InputExpressNumber {
  scan,
  manual
}

class OrderDetailPage extends StatefulWidget {

  /// 订单对象
  OrderModel order;

  /// 查看模式(卖家/买家)
  OrderMode mode;

  /// 刷新订单列表
  dynamic refreshOrderList;


  /// 构造函数,初始化订单和图书对象
  OrderDetailPage(this.order, {this.mode = OrderMode.buyer, this.refreshOrderList});


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return OrderDetailPageState();
  }
}

class OrderDetailPageState extends State<OrderDetailPage> {


  /// 快递单号
  String expressNumber = "";
  TextEditingController _expressNumberController = TextEditingController();

  /// 获取卖家昵称
  String sellerName = "";

  ///定义异步寄存器, 用于FutureBuilder
  AsyncMemoizer _memoization = AsyncMemoizer<dynamic>();

  /// 获取用户信息的延迟加载
  Future<void> getUserInfo() async {
      var user = await UserRequest().getUserByID(widget.order.book.userID);
      sellerName = user.userName;
      widget.order.book.owner = user;
  }


  /// 订单状态区域
  Widget OrderStatusArea() {
    return Container(
      width: double.infinity,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                color: Colors.blue,
              )
          ),

          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 50,
              child: Container(
                color: Colors.white,
              )
          ),

          Positioned(
            top: 15,
            bottom: 10,
            // height: 115,
              left: 20,
              right: 20,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      spreadRadius: 2,
                      color: Color.fromARGB(20, 0, 0, 0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(OrderModel.orderStatusList[widget.order.orderStatus],
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Divider(),
                    Text(
                      widget.mode == OrderMode.buyer ?
                        OrderModel.buyerOrderStatusListHintContent[widget.order.orderStatus] :
                        OrderModel.sellerOrderstatusListHintContent[widget.order.orderStatus],
                      style: TextStyle(color: Colors.black54),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
          ),
        ],
      ),
    );
  }

  /// 商品详情区域
  Widget BookDetailArea(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ShopBookDetailPage(widget.order.book)));
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(left: 15, right: 20, top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: AspectRatio(
                aspectRatio: 3.0 / 3.8, // 宽高比
                child: Container(
                  //height: 20,
                  //padding: EdgeInsets.zero,
                  child: ExtendedImage.network(
                    widget.order.book.coverURL,
                    cache: true,
                    fit: BoxFit.fitHeight,
                    enableLoadState: true,
                    loadStateChanged: (state) {
                      return Utils.loadNetWorkImage(state);
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.order.book.bookName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),),
                        Padding(padding: EdgeInsets.all(3),),
                        Text(
                          ShopBookModel.appearanceList[widget.order.book.appearance],
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.teal
                          ),
                        )
                      ],
                    ),),
                    Text("￥" + widget.order.price.toStringAsFixed(2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 订单信息区域
  Widget PriceArea() {

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        children: [
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("商品总价", style: TextStyle(color: Colors.black38, fontSize: 13),),
              Row(
                children: [
                  Text("￥", style: TextStyle(color: Colors.black38, fontSize: 13),),
                  Text(widget.order.book.price_now.toStringAsFixed(2), style: TextStyle(color: Colors.black38, fontSize: 13),),
                ],
              ),
            ],
          ),
          Padding(padding: EdgeInsets.all(3),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("运费", style: TextStyle(color: Colors.black38, fontSize: 13),),
              Row(
                children: [
                  Text("￥", style: TextStyle(color: Colors.black38, fontSize: 13),),
                  Text(widget.order.book.expressPrice.toStringAsFixed(2), style: TextStyle(color: Colors.black38, fontSize: 13),),
                ],
              ),
            ],
          ),
          Padding(padding: EdgeInsets.all(5),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("实付款", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("￥", style: TextStyle(color: Colors.red, fontSize: 12),),
                  Text(widget.order.price.toStringAsFixed(2), style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w600),),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 顾客信息
  Widget CustomerInfo() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("收货地址：", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
              Text(widget.order.consigneeName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
              Padding(padding: EdgeInsets.all(5)),
              Text(widget.order.consigneePhone, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
            ],
          ),
          Padding(padding: EdgeInsets.all(5)),
          Text(widget.order.consigneeAddress, style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  /// 订单详情
  Widget OrderInfoArea() {

    return FutureBuilder(
        future: _memoization.runOnce(getUserInfo),
        builder: (context, snapshot) {
          return Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("订单信息", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
                Padding(padding: EdgeInsets.all(8)),
                /*
              Text("卖家用户名：" + order.book., style: TextStyle(color: Colors.black54, fontSize: 12),),
              Padding(padding: EdgeInsets.all(4)),
              Text("买家用户名：" , style: TextStyle(color: Colors.black54, fontSize: 12),),
              Padding(padding: EdgeInsets.all(4)),
               */
                Text("卖家昵称：" + sellerName, style: TextStyle(color: Colors.black54, fontSize: 12),),
                Padding(padding: EdgeInsets.all(4)),
                /*
                Text("买家名：" + order., style: TextStyle(color: Colors.black54, fontSize: 12),),
                Padding(padding: EdgeInsets.all(4)),
                 */
                Text("订单编号：" + widget.order.orderID, style: TextStyle(color: Colors.black54, fontSize: 12),),
                Padding(padding: EdgeInsets.all(4)),
                Text("交易时间：" + formatDate(widget.order.createTime, ['yyyy','-','mm','-','dd',' ','HH',':','mm',':','ss']), style: TextStyle(color: Colors.black54, fontSize: 12),),
                Padding(padding: EdgeInsets.all(4)),
              ],
            ),
          );
    });
  }


  // 底部固定栏,购买和购物车按钮
  Widget BottomNavigationArea(BuildContext context) {
    return Container(
      height: 85,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
          color: Colors.white,
          /*
          border: Border(
              top: BorderSide( // 设置单侧边框的样式
                color: Colors.grey,
                width: 0.3,
                style: BorderStyle.solid,
              )
          )

           */
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 10, bottom: 25),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: bottomButtons(context),
        ),
      ),
    );
  }

  /// 页面主体(ListView)
  Widget BodyArea(BuildContext context) {
    return ListView(
      children: [
        OrderStatusArea(),
        BookDetailArea(context),
        PriceArea(),
        Container(height: 10, color: Colors.grey[100],),
        CustomerInfo(),
        Container(height: 10, color: Colors.grey[100],),
        OrderInfoArea(),
      ],
    );
  }

  
  /// 显示填单号对话框
  void showExpressAlert(BuildContext context) {
    
    _expressNumberController.text = expressNumber;
    
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("请输入快递公司给您的快递单号"),
            content: TextField(
              controller: _expressNumberController,
              decoration: InputDecoration(
                hintText: "输入快递单号",
              ),
            ),
            actions: [
              TextButton(
                  child: Text("确定",),
                  onPressed: () async {
                    // 先设置订单里的快递单号
                    widget.order.expressNumber = _expressNumberController.text;
                    // 设置订单状态(1为已发货)
                    widget.order.orderStatus = 1;
                    // 发送请求
                    int result1 = await ShopRequest().changeOrderState(order: widget.order);
                    int result2 = await ShopRequest().setExpress(order: widget.order);
                    // 2个请求都成功才行,1个失败都不行
                    switch (result1 + result2) {
                      case 2:
                        setState(() {
                          Utils.showToast("发货成功", context, mode: ToastMode.Success);
                          widget.order.orderStatus = 1;
                          widget.order.expressNumber = _expressNumberController.text;
                        });
                        Navigator.pop(context);
                        break;
                      default:
                        Utils.showToast("发货失败", context, mode: ToastMode.Error);
                        // 失败后回滚数据
                        widget.order.expressNumber = "";
                        widget.order.orderStatus = 0;
                    }

                  }),
              TextButton(onPressed: () => Navigator.pop(context), child: Text("取消")),
            ],
          );
        }
    );
  }

  /// build方法
  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("订单详情"),
        shadowColor: Colors.transparent,
      ),
      bottomNavigationBar: BottomNavigationArea(context),
      body: BodyArea(context),
    );
  }

  /// 底部按钮逻辑
  List<Widget> bottomButtons(BuildContext context) {
    switch (widget.mode) {
    /// 卖家
      case OrderMode.seller:
      /// 检查订单状态
        switch (widget.order.orderStatus) {
        // 等待发货
          case 0:
            return [Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 30, right: 30, top: 7, bottom: 7 ),
                child: Container(
                    decoration: new BoxDecoration(
                      color: Colors.blue,
                      //设置四周圆角 角度
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      //设置四周边框
                      border: new Border.all(width: 1, color: Colors.transparent),
                    ),
                  //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  // 发货按钮内嵌一个popMenu
                  child: PopupMenuButton<InputExpressNumber> (
                    //color: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    //child: Text("去发货"),
                    child: FlatButton(
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                      child: Text("去发货", style: TextStyle(color: Colors.white, fontSize: 15),),
                    ),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<InputExpressNumber>>[
                      const PopupMenuItem<InputExpressNumber>(
                        value: InputExpressNumber.scan,
                        child: Text("扫描快递单上的条码"),
                      ),
                      const PopupMenuItem<InputExpressNumber>(
                        value: InputExpressNumber.manual,
                        child: Text('手动输入快递单号'),
                      ),
                    ],
                    onSelected: (option) async {
                      if (option == InputExpressNumber.scan) {
                        if (option == InputExpressNumber.scan) {
                          // 扫描条码
                          TargetPlatform platform = Theme.of(context).platform;
                          // iOS扫码
                          if (TargetPlatform.iOS == platform) {
                            expressNumber = await Utils.scanBarcode_iOS(mounted: true);
                            // "-1"代表取消
                            if (expressNumber != "-1") {
                              showExpressAlert(context);
                            }
                          }
                          // 安卓扫码
                          if (TargetPlatform.android == platform) {
                            expressNumber = await Utils.scanBarcode_Android(context: context);
                            showExpressAlert(context);
                          }
                        }
                      } else {
                        showExpressAlert(context);
                      }
                    },
                  )
                  // child: Text("去发货", style: TextStyle(color: Colors.white),),
                  // onPressed: () async {
                  //
                  // },
                ),
              ),
            ),];
            break;
        // 等待收货
          case 1:
            return [
              FlatButton(
                color: Colors.blue,
                //colorBrightness: Brightness.dark,
                //splashColor: Colors.blueAccent,
                shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                child: Text("查询物流", style: TextStyle(color: Colors.white),),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      WebViewPage(title: "物流查询", url: "https://m.kuaidi100.com/app/query/?com=&nu=" + widget.order.expressNumber,)
                  ));
                },
              ),
              Padding(padding: EdgeInsets.all(10)),
            ];
            break;

        // 交易成功
          case 2:
            return [
              FlatButton(
                color: Colors.blue,
                //colorBrightness: Brightness.dark,
                //splashColor: Colors.blueAccent,
                shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                child: Text("查询物流", style: TextStyle(color: Colors.white),),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      WebViewPage(title: "物流查询", url: "https://m.kuaidi100.com/app/query/?com=&nu=" + widget.order.expressNumber,)
                  ));
                },
              ),
              Padding(padding: EdgeInsets.all(5)),
              OutlineButton(
                color: Colors.transparent,
                //colorBrightness: Brightness.dark,
                //splashColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                child: Text("申请客服介入", style: TextStyle(color: Colors.black),),
                onPressed: () {
                  Utils.showToast("暂不支持申请客服介入", context, mode: ToastMode.Warning);
                },
              ),
              Padding(padding: EdgeInsets.all(10)),
            ];
        }
        break;


    /// 买家
      case OrderMode.buyer:
        /// 检查订单状态
        switch (widget.order.orderStatus) {
          // 等待发货
          case 0:
            return [Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 30, right: 30, ),
                child: OutlineButton(
                  //colorBrightness: Brightness.dark,
                  //splashColor: Colors.blueAccent,
                  shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  child: Text("取消订单", style: TextStyle(color: Colors.black),),
                  onPressed: () async {
                    int result = 0;
                    Utils.ShowAlertDialog(context: context,
                      title: "确定取消订单吗？",
                      content: "卖家尚未发货, 您可以随时取消订单",
                      Action1: () async {
                        Utils.showToast("取消订单中...", context, mode: ToastMode.Loading);
                        Navigator.pop(context);
                        result = await ShopRequest().cancelOrder(order: widget.order);

                        if (result == 1) {
                          Utils.showToast("订单取消成功", context, mode: ToastMode.Success);
                        } else {
                          Utils.showToast("订单取消失败", context, mode: ToastMode.Error);
                        }
                        /// 刷新订单列表
                        widget.refreshOrderList();
                        Navigator.pop(context);
                      },

                      Action2: () => Navigator.pop(context),
                    );


                  },
                ),
              ),
            ),];
            break;
          // 等待收货
          case 1:
            return [
              FlatButton(
                color: Colors.blue,
                //colorBrightness: Brightness.dark,
                //splashColor: Colors.blueAccent,
                shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                child: Text("查询物流", style: TextStyle(color: Colors.white),),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      WebViewPage(title: "物流查询", url: "https://m.kuaidi100.com/app/query/?com=&nu=" + widget.order.expressNumber,)
                  ));
                },
              ),
              Padding(padding: EdgeInsets.all(5)),
              FlatButton(
                color: Colors.deepOrange,
                //colorBrightness: Brightness.dark,
                //splashColor: Colors.blueAccent,
                shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                child: Text("确认收货", style: TextStyle(color: Colors.white),),
                onPressed: () {
                  Utils.ShowAlertDialog(context: context,
                      title: "您确认收到了图书吗",
                      content: "确认收货后, 钱款将直接打入卖家账户",
                      Action1: () async {
                        // 先设置订单状态
                        widget.order.orderStatus = 2;
                        int result = await ShopRequest().changeOrderState(order: widget.order);
                        switch (result) {
                          case 1:
                            setState(() {
                              widget.order.orderStatus = 2;
                              Utils.showToast("确认收货成功", context, mode: ToastMode.Success);
                            });
                            break;
                          default:
                            Utils.showToast("确认收货失败", context, mode: ToastMode.Error);
                            widget.order.orderStatus = 1;
                        }
                        Navigator.pop(context);
                      },
                      Action2: () => Navigator.pop(context));
                },
              ),
              Padding(padding: EdgeInsets.all(10)),
            ];
            break;

          // 交易成功
          case 2:
            return [
              FlatButton(
                color: Colors.blue,
                //colorBrightness: Brightness.dark,
                //splashColor: Colors.blueAccent,
                shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                child: Text("查询物流", style: TextStyle(color: Colors.white),),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      WebViewPage(title: "物流查询", url: "https://m.kuaidi100.com/app/query/?com=&nu=" + widget.order.expressNumber,)
                  ));
                },
              ),
              Padding(padding: EdgeInsets.all(5)),
              OutlineButton(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                child: Text("申请客服介入", style: TextStyle(color: Colors.black),),
                onPressed: () {
                  Utils.showToast("暂不支持申请客服介入", context, mode: ToastMode.Warning);
                },
              ),
              Padding(padding: EdgeInsets.all(10)),
            ];


        }

    }
  }
}