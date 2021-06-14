import 'package:flutter/material.dart';
import 'package:my_library/MyBook/Controller/BookShelf/(Deprecated)BookShelfManagePage.dart';
import 'package:my_library/MyBook/Model/BookShelfModel.dart';
import 'package:my_library/MyBook/Model/MyBookModel.dart';

// Function
import 'package:my_library/MyBook/Function/MyBookRequest.dart';

// Views
import 'package:my_library/MyBook/View/BookShelf/BookListDetailCell.dart';

class BookShelfDetailPage extends StatefulWidget {

  BookShelfModel shelf;

  BookShelfDetailPage({this.shelf});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return BookShelfDetailPageState();
  }
}

class BookShelfDetailPageState extends State<BookShelfDetailPage> {

  List<MyBookModel> books = [];

  // 获取书架中的书
  Future<void> getBooks_Network() async {
    var request = MyBookRequest();
    await request.init();
    // print(widget.shelfName);
    if (widget.shelf.shelfID == -1) {
      books = await request.getAllBooks();
    } else {
      books = await request.getBooksFromShelf(shelfName: widget.shelf.shelfName);
    }
  }


  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text(widget.shelf.shelfName),),
      body: FutureBuilder(
        future: getBooks_Network(),
        builder: (context, snapshot) {
          return ListView.builder(
            padding: EdgeInsets.only(top: 5),
            itemCount: books.length,
            itemBuilder: (BuildContext context, int index){
              return BookListDetailCell(
                book: books[index],
                deleteRefreshAction: () {
                  setState(() {
                    books.removeAt(index);
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}