import 'package:flutter/material.dart';

// Views
import 'package:my_library/Shop/View/ShoppingCartCell.dart';

// Models
import 'package:my_library/Shop/Model/ShoppingCartModel.dart';

bool isSelectedAll = false;
ShoppingCartModel shopCart;

class ShoppingCartPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ShoppingCartPageState();
  }
}

class ShoppingCartPageState extends State<ShoppingCartPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("购物车"),
      ),

      bottomNavigationBar: Container(
        height: 100,
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide( // 设置单侧边框的样式
                  color: Colors.grey,
                  width: 0.3,
                  style: BorderStyle.solid,
                )
            )
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: 25),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FlatButton(
                        // 让button的内边距为0
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero,
                        height: 20,
                        minWidth: 1,
                        shape: CircleBorder(),
                        child: Icon(
                          isSelectedAll ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: Colors.blue,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {

                          });
                        },

                      ),
                      Padding(padding: EdgeInsets.all(3)),
                      Text("全选", style: TextStyle(fontSize: 15),)
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 12),
                  child: RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                            text: "已选100件，",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              letterSpacing: 0,
                            )
                        ),
                        TextSpan(
                            text: "合计:",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              letterSpacing: 0,
                            )
                        ),
                        TextSpan(
                            text: "￥",
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 13,
                              letterSpacing: -1,
                            )
                        ),
                        TextSpan(
                            text: "30.00",
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 22.5,
                              letterSpacing: -1,
                            )
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: RaisedButton(
                    child: Text("结算", style: TextStyle(color: Colors.white, fontSize: 16),),
                    color: Colors.deepOrangeAccent,
                    onPressed: (){},),
                ),
              ),
            ],
          ),
        )
      ),

      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ShoppingCartCell();
        }),
    );
  }
}