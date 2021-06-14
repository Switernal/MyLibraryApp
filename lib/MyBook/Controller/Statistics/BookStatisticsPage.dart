import 'package:flutter/material.dart';
import 'package:my_library/MyBook/View/Statistics/BookStatisticsCell.dart';

class BookStatisticPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BookStatisticPageState();
  }
}

class BookStatisticPageState extends State<BookStatisticPage> {


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("书籍统计"),),
      body: ListView.builder(
            itemCount: 6,
            itemBuilder: (context, index) {
              return BookStatisticsCell(index: index);
            })
    );
  }
}