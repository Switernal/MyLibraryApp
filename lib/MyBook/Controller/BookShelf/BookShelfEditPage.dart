import 'package:flutter/material.dart';

// Functions
import 'package:my_library/MyBook/Function/MyBookRequest.dart';
import 'package:my_library/Functions/Utils/Utils.dart';

enum Mode {AddShelf, EditShelf}

String this_shelfName;  // 书柜名称
dynamic this_refreshBookShelf; // 刷新shelf
Mode this_mode; // 编辑模式

// 输入框控制器
TextEditingController textController = TextEditingController();

// 错误文字
String errorText = null;


// 既可以作为编辑书架,也可以作为新增书架,需要判断
class BookShelfEditPage extends StatefulWidget {

  BookShelfEditPage({shelfName, refreshBookShelf, mode}) {
    this_shelfName = shelfName;
    this_refreshBookShelf = refreshBookShelf;
    this_mode = mode;
  }
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BookShelfEditPageState();
  }
}

class BookShelfEditPageState extends State<BookShelfEditPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // 设定初值
    if (this_mode == Mode.EditShelf) {
      // 修改模式下,光标移到最后
      print(this_mode.toString());
      textController.text = this_shelfName;
      textController.selection = TextSelection.fromPosition(
        TextPosition(
            affinity: TextAffinity.downstream,
            offset: this_shelfName.length),
      );
    } else {
      print(this_mode.toString());
      textController.text = "";
    }

  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build 函数

    return Scaffold(
      appBar: AppBar(title: Text(this_mode == Mode.AddShelf ? "添加书柜" : "修改书柜名称"),),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () async {
          if (textController.text == "") {
            setState(() {
              errorText = "书柜名不能为空";
            });
          } else {
            errorText = await this_refreshBookShelf(textController.text);
            setState(() {
              if (errorText == null) {
                Navigator.of(context).pop();
              }
            });
          }
        },
      ),

      body: Padding(
        padding: EdgeInsets.only(top: 30, left: 20, right: 20),
        child: TextField(

          controller: textController,
          keyboardType: TextInputType.text,
          maxLines: 1,
          autofocus: true,
          cursorColor: Colors.blue,
          // maxLength: 11,
          maxLengthEnforced: true,
          //focusNode: FocusNode.,
          decoration: InputDecoration(

            border: OutlineInputBorder(),
            hintText: "请输入书柜名",
            labelStyle: TextStyle(fontSize: 20),
            labelText: "书柜名称",
            errorText: errorText,
            //prefixIcon: Icon(Icons.auto_awesome_motion),
            // 未获得焦点边框设为灰色
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            //获得焦点边框设为蓝色
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),

          ),

          // 监听输入
          onChanged: (text) {
            if (text != "") {
              setState(() {
                errorText = null;
              });
            } else {
              setState(() {
                errorText = "书柜名不能为空";
              });
            }
          },
        ),
      ),
    );
  }
}