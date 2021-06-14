import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_library/MyBook/Model/BookShelfModel.dart';
import 'package:my_library/MyBook/View/BookShelf/BookShelfManageCell.dart';

Map<String, int> shelfNames = {"书房" : 10, "客厅" : 20, "书架" : 30, "卧室" : 40, "储物间" : 40};
var BarEditButton = Icon(Icons.edit, color: Colors.white,);
bool isShowEditButton = false;
double rightPadding = 0.0;

@deprecated
class BookShelfManagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BookShelfManagePageState();
  }
}


@deprecated
class BookShelfManagePageState extends State<BookShelfManagePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("书架管理"),
        actions: [
          IconButton(
              icon: BarEditButton,
              onPressed: () {
                setState(() {
                  isShowEditButton = !isShowEditButton;
                  if (isShowEditButton) {
                    BarEditButton = Icon(Icons.check, color: Colors.white,);
                    rightPadding = 10.0;
                  } else {
                    BarEditButton = Icon(Icons.edit, color: Colors.white,);
                    rightPadding = 0.0;
                  }
                });
              }
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {

        },
      ),
      body: ListView.builder(
        padding: EdgeInsets.only(top: 8),
        itemCount: shelfNames.length,
        itemBuilder: (context, index) {
          return Dismissible(
              key: Key(index.toString()),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {

              },
              background: new Container(color: Colors.red),
              child: Row(
                children: [
                  Expanded(
                    child: BookShelfManageCell(
                        shelf: BookShelfModel(),
                    ),
                  ),
                  // 删除按钮
                  Padding(
                    padding: EdgeInsets.only(right: rightPadding),
                    child: Visibility(
                      child: Container(
                          height: 80,
                          width: 60,
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.redAccent, Colors.red],
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
                        child: FlatButton(
                          child: Text("删除", style: TextStyle(color: Colors.white),),
                          onPressed: () {
                            setState(() {
                              shelfNames.remove(shelfNames.keys.toList()[index]);
                            });
                          },),
                        ),
                      visible: isShowEditButton,
                    ),
                  ),
                ],
              )
          );
        },
      )
          /*
      Row(
        children: [
          Expanded(child: BookShelfManageCell(
            shelfData: BookShelfData(
                shelfName: "书房",
                numbersOfBooks: 200
            ),
          ),)
        ],
      )
      */
           
      // CreditCard(data: CreditCardViewModel(bankName: "招商", bankLogoUrl: "url", cardType: "信用卡", cardNumber: "201983900048", cardColors: [Colors.blue, Colors.green], validDate: "2021-05"),),
    );
  }
}