// TODO: 支付页面

import 'dart:async';
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

// Packages
import 'package:city_pickers/city_pickers.dart';
import 'package:flutter/services.dart';
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/Shop/Function/ShopRequest.dart';
import 'package:my_library/Shop/Model/OrderModel.dart';
import 'package:my_library/Shop/Model/ShopBookModel.dart';
import 'package:my_library/Shop/View/Order/PasswordDialog.dart';
import 'package:tform/tform.dart';
import 'package:local_auth/local_auth.dart';
import 'package:rflutter_alert/rflutter_alert.dart' as rflutter;
// import 'package:pin_code_fields/pin_code_fields.dart' as PinCode;

// Function
import 'package:my_library/Functions/Utils/LocalStorageUtils.dart';



class PaymentPage extends StatefulWidget {

  // 要购买的图书
  ShopBookModel bookToPay;

  // 刷新商店首页
  dynamic refreshShopHomeData;

  PaymentPage(this.bookToPay, {this.refreshShopHomeData}) {
    print("Payment: ${bookToPay.bookName}");
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PaymentPageState();
  }
}

class PaymentPageState extends State<PaymentPage> {

  /// 本地认证框架
  final LocalAuthentication auth = LocalAuthentication();

  /// 生物识别
  Future<bool> _bioAuthenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: '扫描指纹进行身份验证',
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return false;

    return authenticated;
  }

  // 支付按钮
  String textOnPayButton = "确认支付";

  // 新订单
  OrderModel order;

  /// 订单总价 = 商品价格 + 运费价格
  double orderTotalAmount;

  // 表单通过GlobalKey获取,遍历表单组件获取值得内容
  final GlobalKey _customerFormKey = GlobalKey<TFormState>();
  // 地址选择器的Controller
  TextEditingController _areaTextController = TextEditingController();
  // 地址选择框的FocusNode
  FocusNode _areaTextFocusNode = FocusNode();

  /// 收集表单内容
  Map<String, dynamic> consigneeInfo = {
    "收货人姓名": "",
    "收货人电话": "",
    "收货人地区": "",
    "收货人地址" : "",
  };

  /// 存区域码信息, 不然下次选择滚轮时, 不是上次选择的位置
  /// 预设为320111, 江苏省南京市浦口区
  String locationID = "320111";

  /// 支付密码是手机号后6位
  String payPassword = "";
  // 异步获取手机号(支付密码用)
  Future<void> _getPhone() async {
    payPassword = await LocalStorageUtils.getUserPhone_Local();
    /// 支付密码是手机号前6位
    print(payPassword);
    payPassword = payPassword.substring(0, 6);
    // await LocalStorageUtils.getUserPhone_Local().then((value) => consigneeInfo["手机号"] = value);
  }

  @override
  void initState() {
    super.initState();
    // 计算订单总价
    orderTotalAmount = widget.bookToPay.price_now + widget.bookToPay.expressPrice;
  }


  /// 页面主体区域
  Widget BodyArea() {
    return TForm.builder(
      key: _customerFormKey,
      rows: buildFormRows(),

    );
  }

  /// 商品详情区域
  Widget BookDetailArea() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 10, right: 20, top: 20),
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
                  widget.bookToPay.coverURL,
                  cache: true,
                  fit: BoxFit.fitHeight,
                  mode: ExtendedImageMode.gesture,
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
              padding: EdgeInsets.only(left: 5, top: 10, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.bookToPay.bookName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),),
                      Padding(padding: EdgeInsets.all(3),),
                      Text(
                        ShopBookModel.appearanceList[widget.bookToPay.appearance],
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.teal
                        ),
                      )
                    ],
                  ),),
                  Text("￥" + widget.bookToPay.price_now.toStringAsFixed(2)),
                ],
              ),
            ),
          ),
        ],
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
                  Text(widget.bookToPay.price_now.toStringAsFixed(2), style: TextStyle(color: Colors.black38, fontSize: 13),),
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
                  Text(widget.bookToPay.expressPrice.toStringAsFixed(2), style: TextStyle(color: Colors.black38, fontSize: 13),),
                ],
              ),
            ],
          ),
          Padding(padding: EdgeInsets.all(5),),

          // 总价 保留两位小数
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("小计", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("￥", style: TextStyle(color: Colors.red, fontSize: 12),),
                  Text(orderTotalAmount.toStringAsFixed(2), style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w600),),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 整体图书区域
  Widget BookArea() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("订单详情", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              Divider(),
            ],
          ),
        ),
        BookDetailArea(),
        PriceArea(),
      ],
    );
  }


  // 底部固定栏,购买按钮
  Widget BottomNavigationArea(BuildContext context) {
    return Container(
      //height: 85,
      padding: EdgeInsets.fromLTRB(30, 5, 30, 20),
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide( // 设置单侧边框的样式
                color: Colors.grey,
                width: 0.3,
                style: BorderStyle.solid,
              )
          )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("实付款："),
          Text("￥", style: TextStyle(color: Colors.red, fontSize: 12),),
          Text(orderTotalAmount.toStringAsFixed(2), style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w600),),
          Padding(padding: EdgeInsets.all(10)),
          FlatButton(
            //colorBrightness: Brightness.dark,
            //splashColor: Colors.blueAccent,
            color: Colors.deepOrange,
            shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            child: Text("确认购买", style: TextStyle(color: Colors.white),),
            onPressed: () async {

              ConfirmPayment(context);


                /*
              // 向服务器发送订单
              int result = await ShopRequest().createOrder(order: newOrder);

              // 根据订单创建结果执行操作
              switch (result) {
                case 1:
                  Utils.showToast("购买成功", context, mode: ToastMode.Success);
                  // 刷新商店首页
                  //widget.refreshShopHomeData();
                  // Navigator.pop(context);
                  Navigator.pop(context, ModalRoute.withName("ShopDetailPage"));
                  break;

                default:
                  Utils.showToast("购买失败", context, mode: ToastMode.Error);
                  return;
              }

                 */
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("确认订单"),
      ),
      bottomNavigationBar: BottomNavigationArea(context),
      body: BodyArea(),
    );
  }


  EdgeInsets TextFieldPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 10);

  /// 表单组件
  List<TFormRow> buildFormRows() {

    return [
      /// 0 填写收货人信息
      TFormRow.customCellBuilder(
        require: false,
        title: "填写收货人信息",
        tag: "blank",
        widgetBuilder: (context, row) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("填写收货人信息", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                Divider(),
              ],
            ),
          );
        }
      ),

      /// 1 姓名
      TFormRow.customCellBuilder(
        require: true,
        title: "姓名",
        tag: "name",
        widgetBuilder: (context, row) {
          return Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Row(
              children: [
                Text("姓名", style: TextStyle(fontSize: 14)),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 30),
                    child: TextField(
                      onChanged: (name) {
                        consigneeInfo["收货人姓名"] = name;
                      },
                      onSubmitted: (value) {

                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0 , vertical: 1),

                        hintText: "请输入收货人姓名",
                        hintStyle: TextStyle(color: Colors.black38),
                        labelStyle: TextStyle(fontSize: 18),
                        fillColor: Colors.blue[50],
                        filled: true,
                        //未获得焦点边框设为蓝色
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue[50],
                            width: 0.0, ),
                        ),
                        //获得焦点边框设为蓝色
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue[50],
                            width: 0.0, ),
                        ),

                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),

      /// 2 电话
      TFormRow.customCellBuilder(
        require: true,
        title: "电话",
        tag: "phone",
          widgetBuilder: (context, row) {
            return Container(
              padding: TextFieldPadding,
              child: Row(
                children: [
                  Text("电话", style: TextStyle(fontSize: 14)),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: TextField(
                        onChanged: (phone) {
                          consigneeInfo["收货人电话"] = phone;
                        },
                        maxLength: 11,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10.0 , vertical: 1),
                          hintText: "请输入收货人电话",
                          hintStyle: TextStyle(color: Colors.black38),
                          labelStyle: TextStyle(fontSize: 18),
                          // 不显示字数提示文字
                          counterText: "",
                          fillColor: Colors.blue[50],
                          filled: true,
                          //未获得焦点边框设为蓝色
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue[50],
                              width: 0.0, ),
                          ),
                          //获得焦点边框设为蓝色
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue[50],
                              width: 0.0, ),
                          ),

                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
      ),

      /*
      /// 2 地区选择框
      TFormRow.customSelector(
        require: true,
        title: "地区",
        tag: "area",
        placeholder: "请选择收货地区",
        onTap: (context, row) async {
          // 获取选择器中选择地址
          Result locationResult = await Utils.showCityPicker(context, areaID: locationID);
          // 存一下AreaID, 下次直接在选择器中显示
          locationID = locationResult.areaId;
          setState(() {
            row.value = locationResult.provinceName + locationResult.cityName + locationResult.areaName;
          });
        },
        fieldConfig: TFormFieldConfig(
          selectorIcon: SizedBox.shrink(),
        ),
      ),

       */

      /// 3 通过textField实现地址选择
      TFormRow.customCellBuilder(
          require: true,
          title: "地区",
          tag: "area",
          widgetBuilder: (context, row) {
            return Container(
              padding: TextFieldPadding,
              child: Row(
                children: [
                  Text("地区", style: TextStyle(fontSize: 14)),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: TextField(
                        autofocus: false,
                        focusNode: _areaTextFocusNode,
                        controller: _areaTextController,
                        // onChanged: (area) {
                        //   consigneeInfo["收货人地区"] = area;
                        // },
                        onTap: () async {
                          // 必须点击后先失去焦点,否则后面键盘收不回去
                          _areaTextFocusNode.unfocus();
                          // 获取选择器中选择地址
                          Result locationResult = await Utils.showCityPicker(context, areaID: locationID);
                          // 存一下AreaID, 下次直接在选择器中显示
                          locationID = locationResult.areaId;
                          setState(() {
                            _areaTextController.text = locationResult.provinceName + locationResult.cityName + locationResult.areaName;
                            consigneeInfo["收货人地区"] = _areaTextController.text;
                            print(consigneeInfo["收货人地区"]);
                          });
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10.0 , vertical: 1),
                          hintText: "请选择地址区域",
                          hintStyle: TextStyle(color: Colors.black38),
                          labelStyle: TextStyle(fontSize: 18),
                          fillColor: Colors.blue[50],
                          filled: true,
                          //未获得焦点边框设为蓝色
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue[50],
                              width: 0.0, ),
                          ),
                          //获得焦点边框设为蓝色
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue[50],
                              width: 0.0, ),
                          ),

                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
      ),

      /// 4 地址输入框
      TFormRow.customCellBuilder(
          require: true,
          title: "地址",
          tag: "address",
          widgetBuilder: (context, row) {
            return Container(
              padding: TextFieldPadding,
              child: Row(
                children: [
                  Text("地址", style: TextStyle(fontSize: 14)),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: TextField(
                        onChanged: (address) {
                          consigneeInfo["收货人地址"] = address;
                        },
                        // 支持多行自适应

                        // keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        minLines: 1,
                        // TextField样式
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10.0 , vertical: 10),

                          hintText: "请输入详细收货地址",
                          hintStyle: TextStyle(color: Colors.black38),
                          labelStyle: TextStyle(fontSize: 18),
                          fillColor: Colors.blue[50],
                          filled: true,
                          //未获得焦点边框设为蓝色
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue[50],
                              width: 0.0, ),
                          ),
                          //获得焦点边框设为蓝色
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue[50],
                              width: 0.0, ),
                          ),

                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
      ),

      // 5 图书详情
      TFormRow.customCellBuilder(
        require: false,
        title: "图书信息",
        tag: "bookDetail",
        widgetBuilder: (context, row) {
          return BookArea();
        }
      ),

    ];
  }

  /// 确认购买
  Future<bool> ConfirmPayment(BuildContext context) async {

    // 是否支付成功
    bool isSuccess = true;

    // 表单是否存在问题
    var existError = false;

    // 先对表单进行合法性判断
    consigneeInfo.forEach((key, value) {
      if (value == "") {
        Utils.showToast("$key 不能为空", context, mode: ToastMode.Warning);
        existError = true;
        return false;
      }
    });


    if (Utils.isPhoneValid(consigneeInfo["收货人电话"]) == false) {
      Utils.showToast("请输入正确的手机号", context, mode: ToastMode.Warning);
      existError = true;
      return false;
    }

    // 如果有错误, 不执行下面的购买操作
    if (existError) return false;

    // 生成订单号 = 卖家id + 买家id + 时间戳
    int buyer_userID = await LocalStorageUtils.getUserID_Local();
    int seller_userID = widget.bookToPay.userID;
    String newOrderID = seller_userID.toString() + buyer_userID.toString() + DateTime.now().millisecondsSinceEpoch.toString();

    // 创建订单
    OrderModel newOrder = OrderModel(
        orderID: newOrderID,
        bookID: widget.bookToPay.bookID,
        userID: buyer_userID,
        createTime: DateTime.now(),
        price: orderTotalAmount,
        consigneeName: consigneeInfo["收货人姓名"],
        consigneePhone: consigneeInfo["收货人电话"],
        consigneeAddress: consigneeInfo["收货人地区"] + consigneeInfo["收货人地址"],
        orderStatus: 0,
        book: widget.bookToPay
    );

    // 支付确认alert样式
    var confirmAlertStyle = rflutter.AlertStyle(
      animationType: rflutter.AnimationType.fromBottom,
      isCloseButton: true,
      isOverlayTapDismiss: false,
      // descStyle: TextStyle(fontSize: 50),
      //descTextAlign: TextAlign.start,
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
        side: BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: TextStyle(
        color: Colors.black,
        fontSize: 35,
      ),
      alertAlignment: Alignment.bottomCenter,
    );

    // 密码输入alert样式
    var passwordAlertStyle = rflutter.AlertStyle(
      animationType: rflutter.AnimationType.fromBottom,
      isCloseButton: true,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(fontSize: 14, color: Colors.black26),
      descTextAlign: TextAlign.center,
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
        side: BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),
      alertAlignment: Alignment.center,
    );


    // 密码输入控制
    TextEditingController passwordController = TextEditingController();

    // 三个Alert的声明
    rflutter.Alert errorAlert;
    rflutter.Alert confirmAlert;
    rflutter.Alert passwordAlert;

    errorAlert = rflutter.Alert(
      context: context,
      type: rflutter.AlertType.error,
      title: "支付失败",
      desc: "密码不正确",
      style: rflutter.AlertStyle(
        descStyle: TextStyle(color: Colors.grey, fontSize: 16),
      ),
      buttons: [
        rflutter.DialogButton(
          child: Text(
            "再试一次",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () {
            Navigator.pop(context);
            confirmAlert.show();
          },
          //width: 60,
        ),
        rflutter.DialogButton(
          child: Text(
            "取消",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () => Navigator.pop(context),
          //width: 60,
        )
      ],
    );

    // 密码输入alert
    passwordAlert = rflutter.Alert(
      context: context,
      //type: AlertType.error,
      style: passwordAlertStyle,
      title: "请输入支付密码",
      desc: "默认支付密码为注册账号时的手机号前6位",
      content: Padding(
        padding: EdgeInsets.all(10),
        child: TextField(
          maxLength: 6,
          obscureText: true,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.visiblePassword,
          controller: passwordController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0 , vertical: 1),
            hintText: "",
            hintStyle: TextStyle(color: Colors.black38),
            labelStyle: TextStyle(fontSize: 18),
            // 不显示字数提示文字
            // counterText: "",
            fillColor: Colors.white,
            filled: true,
            //未获得焦点边框设为蓝色
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 0.0, ),
            ),
            //获得焦点边框设为蓝色
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 0.0, ),
            ),

          ),
        ),
      ),
      buttons: [
        rflutter.DialogButton(
          child: Text(
            "确认支付",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () async {
            // 获取手机号得到密码
            await _getPhone();
            // 密码正确
            if (passwordController.text == payPassword) {
              // 向服务器发送订单
              int result = await ShopRequest().createOrder(order: newOrder);

              // 根据订单创建结果执行操作
              switch (result) {
                case 1:
                  Utils.showToast("购买成功", context, mode: ToastMode.Success);
                  isSuccess = true;
                  Navigator.pop(context);
                  Navigator.pop(context, ModalRoute.withName("ShopDetailPage"));
                  break;

                default:
                  Utils.showToast("购买失败", context, mode: ToastMode.Error);
                  Navigator.pop(context);
              }
            } else {
              //Utils.showToast("密码错误, 支付失败", context, mode: ToastMode.Error);
              Navigator.pop(context);
              errorAlert.show();
            }

          },
        )
      ],
    );

    // 支付确认alert
    confirmAlert = rflutter.Alert(
      context: context,
      //type: AlertType.error,
      style: confirmAlertStyle,
      title: "￥" + newOrder.price.toStringAsFixed(2),
      content: Column(
        children: <Widget>[
          ListTile(title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("支付账户", style: TextStyle(fontSize: 14, color: Colors.black45),),
              Text(consigneeInfo["收货人电话"], style: TextStyle(fontSize: 14, color: Colors.grey),)
            ],
          ),),
          ListTile(title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("支付方式", style: TextStyle(fontSize: 14, color: Colors.black45),),
              Text("余额", style: TextStyle(fontSize: 14, color: Colors.grey),)
            ],
          )),
        ],
      ),
      buttons: [
        rflutter.DialogButton(
          child: Text(
            "同意协议并支付",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () async {
            // 先识别, 如果成功则支付成功
            if (await _bioAuthenticate() == true) {
              // 识别成功
              // 向服务器发送订单
              int result = await ShopRequest().createOrder(order: newOrder);

              // 根据订单创建结果执行操作
              switch (result) {
                case 1:
                  Utils.showToast("购买成功", context, mode: ToastMode.Success);
                  isSuccess = true;
                  Navigator.pop(context);
                  Navigator.pop(context, ModalRoute.withName("ShopDetailPage"));
                  break;

                default:
                  Utils.showToast("购买失败", context, mode: ToastMode.Error);
              }

            } else {
              // 识别失败, 使用密码支付
              Utils.showToast("识别失败, 请使用密码支付", context, mode: ToastMode.Error);
              Navigator.pop(context);
              passwordAlert.show();
            }

          },
        )
      ],
    );

    // 先显示确认支付框
    confirmAlert.show();


    return isSuccess;
  }
}