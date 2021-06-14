
import 'package:flutter/material.dart';

import 'dart:convert';

// Models
import 'package:my_library/MyBook/Model/MyBookModel.dart';

class BookShelfModel {
  // 书柜ID
  int shelfID;
  // 书柜名
  String shelfName;
  // 藏书数量
  int counts;
  List<MyBookModel> books;
  List<dynamic> data;

  BookShelfModel({@required this.shelfName, this.books, this.shelfID}) {
    if (this.books == null) {
      counts = 0;
      books = [];
    } else {
      counts = books.length;
    }

  }


  // 转Json
  Map<String, dynamic> toJson() => <String, dynamic> {
    'shelfName': shelfName,
    'counts': counts.toString(),
    'books': books  //json.decode(json.encode(books))  多此一举
  };

  // Json转Shelf (Local本地方法)
  BookShelfModel.fromJson_Local(Map<String, dynamic> jsonData) :
    shelfName = jsonData['shelfName'],
    //counts = int.parse(jsonData['counts']),
    data = jsonData['books']
  {
      books = [];
      for (var book in data) {
        books.add(MyBookModel.fromJson_Local(book));
      }

      counts = books.length;
  }

  //  Json转Shelf (网络方法)
  BookShelfModel.fromJson_Network(Map<String, dynamic> jsonData) :
    shelfID = jsonData['shelf_id'],
    shelfName = jsonData['shelfName'],
    counts = jsonData['countOfBooks'];

  @override
  String toString() {
    // TODO: implement toString
    return "shelfName : " + shelfName + "\n"
        + "shelfID : " + shelfID.toString() + "\n"
        + "counts : " + counts.toString();
  }

}