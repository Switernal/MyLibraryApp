import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class Network {

  /// 文件URL
  static final String filePath = "assets/NetworkConfig.yaml";

  /// 缓存文件数据
  static dynamic fileData;

  /// 服务器URL列表
  List<String> servers = [];

  /// 当前选择的服务器
  String currentServer = "";

  /// 缓存对象, 每次创造新对象时调用工厂构造函数,不产生新对象
  static Network _defaultObject = Network._privateConstructor();

  /// 私有命名构造函数
  Network._privateConstructor() {
    // 啥也没干, 就是初始化用的命名构造方法, 给缓存对象用的
  }

  /// 工厂构造方法
  factory Network() {
    // print("MyBookRequest factory constructor");
    return Network._defaultObject;
  }

  /// 获取文件内容
  Future<void> readFileData() async {
    var content = await rootBundle.loadString(filePath);
    var data = loadYaml(content);
    Network.fileData = data; // 将读出的文件内容放到缓存(static)
  }

  /// 初始化获取数据
  Future<bool> init() async {
    await readFileData();
    servers = getServerAllURLs();
    currentServer = servers[0];
    return true;
  }


  /* 对外方法 */

  /// 获取服务器所有的URL
  List<String> getServerAllURLs() {
    //var data = await readFileData();
    List<String> serverURLs = [];
    fileData["server"]["url"].forEach(
      (element) {
        serverURLs.add(element);
      }
    );
    return serverURLs;
  }

  /// 选择服务器(默认服务器为第0个)
  void selectServer({@required int index = 0}) {
    currentServer = servers[index];
  }

  /// 获取服务器URL
  String getServerURL() {
    return currentServer;
  }



  /// 获取所有路由
  Map<dynamic, dynamic> getAllRoutes() {
    //var data = await readFileData();
    return fileData["routes"];
  }

  /// 获取查询图书路由
  dynamic getSearchBookRoute() {
    //var data = await readFileData();
    return fileData["routes"]["searchBookByISBN"];
  }

  /// 获取所有MyBook路由
  Map<dynamic, dynamic> getMyBookRoutes() {
    //var data = await readFileData();
    return fileData["routes"]["MyBook"];
  }

  /// 获取用户路由
  Map<dynamic, dynamic> getUserRoutes() {
    //var data = await readFileData();
    return fileData["routes"]["User"];
  }

  /// 获取商店路由
  Map<dynamic, dynamic> getShopRoutes() {
    //var data = await readFileData();
    return fileData["routes"]["Shop"];
  }

}