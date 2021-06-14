
// Functions
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_library/Functions/Network/Network.dart';
import 'package:my_library/Functions/Utils/LocalStorageUtils.dart';

// Packages
import 'package:dio/dio.dart';
import 'package:my_library/Shop/Model/OrderModel.dart';
import 'package:my_library/Shop/Model/ShopBookModel.dart';

/*
  # Shop的所有路由
  Shop:
    Query:
      searchGood_ID: "/goods/searchGood"            # 通过商品ID查找商品
      getUserGoods: "/goods/getPublishGoods"        # 获取用户发布的所有商品
      getUserOrders: "/orderList/searchUserList"    # 获取用户所有订单
      getOrderByGoodID: "/orderList/searchOrderByGood"  # 根据商品ID查找订单信息
      searchGoodByName: "/goods/searchGoodsLike"    # 根据书名在商店中查找
      getRandomGoods: "/goods/loadGoods"            # 随机加载商店中20个商品

    Add:
      addShopBook: "/goods/addGood"                 # 发布新商品
      createOrder: "/orderList/addOrderList"        # 创建新订单

    Update:
      changePrice: "/goods/changePrice"             # 修改商品价格
      changeOrderState: "/orderList/changeState"    # 更新订单状态
      setExpress: "/orderList/setExpress"           # 修改快递单号

    Delete:
      cancelOrder: "/orderList/cancelList"          # 取消订单
 */



class ShopRequest {
  /// 接口地址
  static String url = "";

  /// UserID
  int UserID = 0;

  /// 所有路由
  Map allShopRoutes = {};
  Map queryRoutes;  // 查询路由
  Map addRoutes;    // 新增路由
  Map updateRoutes; // 修改路由
  Map deleteRoutes; // 删除路由

  /// 缓存对象,每次创造新对象时调用工厂构造函数,不产生新对象
  static ShopRequest _defaultObject = ShopRequest._privateConstructor();

  /// 私有命名构造函数
  ShopRequest._privateConstructor() {
    // TODO: Do nothing
  }


  /// 工厂构造方法
  factory ShopRequest() {
    url = Network().getServerURL();
    return ShopRequest._defaultObject;
  }

  /// 获取Shop的所有路由和UserID
  Future<bool> init() async {
    url = Network().getServerURL();
    allShopRoutes = Network().getShopRoutes();
    await LocalStorageUtils.getUserID_Local().then((value) => this.UserID = value);

    queryRoutes = allShopRoutes["Query"];
    addRoutes = allShopRoutes["Add"];
    updateRoutes = allShopRoutes["Update"];
    deleteRoutes = allShopRoutes["Delete"];

    return true;
  }

  /* 商品接口 */
  /* 查询类 */


  /// 1. 通过商品ID查找商品
  /// status:
  //    1--成功
  //    0--商品不存在
  Future<ShopBookModel> searchGoodByID({@required int goodID}) async {
    // 路由
    var route = queryRoutes["searchGoodByID"];
    // 参数
    Map<String, dynamic> paras = {
      "good_id" : goodID,
    };
    // 发起请求
    var response = await Dio().get(url + route, queryParameters: paras);
    // 解析数据
    var jsonData = response.data;
    // 判断状态码
    if (jsonData["status"] == 1) {
      return ShopBookModel.fromJson_Network(response.data["obj"]);
    } else {
      return ShopBookModel();
    }
  }

  /// 2. 根据书名在商店中查找
  /// status:
  //     1--成功
  //     0--没有查到商品
  Future<List<ShopBookModel>> searchGoodByName({@required String goodName}) async {
    // 路由
    var route = queryRoutes["searchGoodByName"];
    // 参数
    Map<String, dynamic> paras = {
      "bookName" : goodName,
    };
    // 发起请求
    var response = await Dio().get(url + route, queryParameters: paras);
    // 解析数据
    var jsonData = response.data;

    // 返回数据
    List<ShopBookModel> goods = [];
    List<dynamic> goodsData = jsonData["obj"];

    // 判断状态码
    if (jsonData["status"] == 1) {
      // 依次解析每个商品
      goodsData.forEach((goodData) {
        goods.add(ShopBookModel.fromJson_Network(goodData));
      });
      return goods;
    } else {
      return [];
    }
  }

  /// 3. 通过订单ID查询订单
  Future<OrderModel> searchOrderByID({@required String orderID}) async {
    // 路由
    var route = queryRoutes["searchOrderByID"];
    // 参数
    Map<String, dynamic> paras = {
      "orderID" : orderID,
    };
    // 发起请求
    var response = await Dio().get(url + route, queryParameters: paras);
    // 解析数据
    var jsonData = response.data;
    // 判断状态码
    if (jsonData["status"] == 1) {
      return OrderModel.fromJson_Network(response.data["obj"]);
    } else {
      // 不是很安全
      return null;
    }
  }

  /// 4.根据商品ID查找订单信息
  /// status:
  //     1--成功
  //     0--没有订单
  Future<OrderModel> searchOrderByGoodID({@required int goodID}) async {
    // 路由
    var route = queryRoutes["searchOrderByGoodID"];
    // 参数
    Map<String, dynamic> paras = {
      "good_id" : goodID,
    };
    // 发起请求
    var response = await Dio().get(url + route, queryParameters: paras);
    // 解析数据
    var jsonData = response.data;
    // 判断状态码
    if (jsonData["status"] == 1) {
      return OrderModel.fromJson_Network(response.data["obj"]);
    } else {
      // 不是很安全
      return null;
    }
  }

  /// 5. 获取卖出的所有商品
  /// status:
  //    1--成功
  //    0--没有发布商品
  Future<List<ShopBookModel>> getSellerGoods() async {
    // 路由
    var route = queryRoutes["getSellerGoods"];
    // 参数
    Map<String, dynamic> paras = {
      "user_id" : UserID,
    };
    // 发起请求
    var response = await Dio().get(url + route, queryParameters: paras);
    // 解析数据
    var jsonData = response.data;

    // 返回数据
    List<ShopBookModel> goods = [];
    List<dynamic> goodsData = jsonData["obj"];

    // 判断状态码
    if (jsonData["status"] == 1) {
      // 依次解析每个商品
      goodsData.forEach((goodData) {
        goods.add(ShopBookModel.fromJson_Network(goodData));
      });
      return goods;
    } else {
      return [];
    }
  }
  

  /// 6. 获取卖出的商品订单
  /// status:
  //     1--成功
  //     0--没有订单
  Future<List<OrderModel>> getSellerOrders() async {
    // 路由
    var route = queryRoutes["getSellerOrders"];
    // 参数
    Map<String, dynamic> paras = {
      "publisher_id" : UserID,
    };
    // 发起请求
    var response = await Dio().get(url + route, queryParameters: paras);
    // 解析数据
    var jsonData = response.data;

    // 返回数据
    List<OrderModel> orders = [];
    List<dynamic> ordersData = jsonData["obj"];

    // 判断状态码
    if (jsonData["status"] == 1) {
      // 依次解析每个商品
      ordersData.forEach((orderData) {
        orders.add(OrderModel.fromJson_Network(orderData));
      });
      return orders;
    } else {
      return [];
    }
  }
  

  /// 7. 获取买到商品的全部订单
  /// status:
  //     1--成功
  //     0--没有订单
  Future<List<OrderModel>> getBuyerOrders() async {
    // 路由
    var route = queryRoutes["getBuyerOrders"];
    // 参数
    Map<String, dynamic> paras = {
      "user_id" : UserID,
    };
    // 发起请求
    var response = await Dio().get(url + route, queryParameters: paras);
    // 解析数据
    var jsonData = response.data;

    // 返回数据
    List<OrderModel> orders = [];
    List<dynamic> ordersData = jsonData["obj"];

    // 判断状态码
    if (jsonData["status"] == 1) {
      // 依次解析每个商品
      ordersData.forEach((orderData) {
        orders.add(OrderModel.fromJson_Network(orderData));
      });
      return orders;
    } else {
      return [];
    }
  }
  

  /// 8. 随机加载商店中20个商品
  /// status:
  //     1--成功
  //     0--商城没有商品
  Future<List<ShopBookModel>> getRandomGoods_20() async {
    // 路由
    var route = queryRoutes["getRandomGoods"];
    // 发起请求
    var response = await Dio().get(url + route);
    // 解析数据
    var jsonData = response.data;

    // 返回数据
    List<ShopBookModel> goods = [];
    List<dynamic> goodsData = jsonData["obj"];

    // 判断状态码
    if (jsonData["status"] == 1) {
      // 依次解析每个商品
      goodsData.forEach((goodData) {
        goods.add(ShopBookModel.fromJson_Network(goodData));
      });
      return goods;
    } else {
      return [];
    }
  }

  /* 新增类 */

  /// 1. 发布新商品
  /// status:
  //    1--成功
  //    0--插入失败
  Future<int> addShopBook({@required ShopBookModel good}) async {
    // 路由
    var route = addRoutes["addShopBook"];
    // 参数
    Map<String, dynamic> body = good.toJson();
    // 修改一下UserID, 那个商品里默认的UserID是空的
    body['user_id'] = UserID;

    // 发起请求
    var response = await Dio().post(url + route, data: body);
    // 解析数据
    return response.data["status"];
  }

  /// 2. 创建新订单
  /// status:
  // 	  1--成功
  //    0--插入失败
  Future<int> createOrder({@required OrderModel order}) async {
    // 路由
    var route = addRoutes["createOrder"];
    // 参数
    var body = json.encode(order);

    // print(body);

    // 发起请求
    var response = await Dio().post(url + route, data: body);
    // 解析数据
    return response.data["status"];
  }

  /* 修改类 */

  /// 1. 修改商品信息
  /// status:
  //    1--成功
  //    0--修改失败
  //    -1--商品不存在
  //    -2--商品已卖出，禁止修改
  Future<int> changeGoods({@required ShopBookModel good}) async {
    // 路由
    var route = updateRoutes["changeGoods"];
    // 参数
    Map<String, dynamic> paras = {
      "good_id" : good.bookID,
      "conditions" : good.appearance,
      "newPrice" : good.price_now,
      "expressPrice" : good.expressPrice,
      "introduction" : good.introduction,
      "coverUrl" : good.coverURL,
    };

    // 发起请求
    var response = await Dio().get(url + route, queryParameters: paras);

    // 解析数据
    return response.data["status"];
  }

  /// 2. 更新订单状态
  /// status：
  //     1--成功
  //     0--修改失败
  //
  // state：
  //     0--已付款
  //     1--已发货
  //     2--交易成功
  Future<int> changeOrderState({@required OrderModel order}) async {
    // 路由
    var route = updateRoutes["changeOrderState"];
    // 参数
    Map<String, dynamic> paras = {
      "orderID" : order.orderID,
      "state" : order.orderStatus,
    };

    // 发起请求
    var response = await Dio().get(url + route, queryParameters: paras);
    // 解析数据
    return response.data["status"];
  }

  /// 3. 修改快递单号
  /// status:
  //     1--成功
  //     0--失败
  Future<int> setExpress({@required OrderModel order}) async {
    // 路由
    var route = updateRoutes["setExpress"];
    // 参数
    Map<String, dynamic> paras = {
      "orderID" : order.orderID,
      "expressNumber" : order.expressNumber,
    };

    // 发起请求
    var response = await Dio().get(url + route, queryParameters: paras);

    // 解析数据
    return response.data["status"];
  }

  /* 删除类 */

  /// 1. 取消订单
  /// status：
  //     1--成功
  //     0--删除失败
  Future<int> cancelOrder({@required OrderModel order}) async {
    // 路由
    var route = deleteRoutes["cancelOrder"];
    // 参数
    Map<String, dynamic> paras = {
      "orderID" : order.orderID,
    };

    // 发起请求
    var response = await Dio().get(url + route, queryParameters: paras);

    // 解析数据
    return response.data["status"];
  }

  /// 2. 删除商品（仅限未卖出的)
  /// status:
  //   1--删除成功
  //   0--删除失败
  //   -1--商品已卖出，禁止删除
  Future<int> deleteGoods({@required ShopBookModel good}) async {
    // 路由
    var route = deleteRoutes["deleteGoods"];
    // 参数
    Map<String, dynamic> paras = {
      "good_id" : good.bookID,
    };

    // 发起请求
    var response = await Dio().get(url + route, queryParameters: paras);

    // 解析数据
    return response.data["status"];
  }
}
