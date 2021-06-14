import 'package:flutter/material.dart';


class ShoppingCartCell extends StatefulWidget {

  bool this_isSelected = false;

  ShoppingCartCell() {

  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ShoppingCartCellState();
  }
}

class ShoppingCartCellState extends State<ShoppingCartCell> {

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.only(left: 10, right: 20),
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
                      widget.this_isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: Colors.blue,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        widget.this_isSelected = !widget.this_isSelected;
                      });
                    },

                  ),
                ],
              ),
            ),
            Container(
              height: 80,
              child: AspectRatio(
                aspectRatio: 3.0 / 4.0, // 宽高比
                child: Container(
                  child: Image.asset('assets/images/txr.jpg', fit: BoxFit.fitHeight,),
                  //margin: EdgeInsets.fromLTRB(30, 20, 20, 20),
                  //padding: EdgeInsets.zero,
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(10)),
            Column(
              children: [
                Text("云雀叫了一整天"),
                Text("￥12.80"),
              ],
            ),
          ],
        ),
      )
    );
  }
}