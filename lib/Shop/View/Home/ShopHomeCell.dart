// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/Shop/Controller/Book/ShopBookDetailPage.dart';
import 'package:my_library/Shop/Function/ShopRequest.dart';
import 'package:my_library/Shop/Model/ShopBookModel.dart';


// Packages
import 'package:extended_image/extended_image.dart';
import 'package:my_library/Shop/Model/ShopBookModel.dart';
import 'package:my_library/User/Function/UserRequest.dart';
class ShopHomeCellData {

}

// 商店首页Cell
class ShopHomeCell extends StatelessWidget {

  ShopBookModel book;

  ShopHomeCell({@required this.book});

  /// 获取用户信息的延迟加载
  Future<void> getUserInfo() async {
    this.book.owner = await UserRequest().getUserByID(this.book.userID);
  }

  // Cell封面图片
  Widget CoverArea() {

    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
        child: ExtendedImage.network(
          book.coverURL,
          cache: true,
          enableLoadState: true,
          loadStateChanged: (state) {
            return Utils.loadNetWorkImage(state);
          },
        ),
            /*
        CachedNetworkImage(
          imageUrl: "https://img3.doubanio.com/view/subject/l/public/s25948080.jpg",
          // fit: BoxFit.fitHeight,
          // placeholder: (context, url) => Container(padding: EdgeInsets.all(20),child: Center(child: AspectRatio(aspectRatio: 1, child: CircularProgressIndicator(strokeWidth: 4,),),),),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
             */
        // Image.network("https://img3.doubanio.com/view/subject/l/public/s25948080.jpg"),
        //Image.network("https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg13.360buyimg.com%2FpopWaterMark%2Fjfs%2Ft505%2F112%2F896234250%2F483302%2Ff7f2d82d%2F5498e4caNcb1cbe47.jpg&refer=http%3A%2F%2Fimg13.360buyimg.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1624344552&t=8bb260f722a0ca7d5abd6a1f924c38d0"),
        // Image.network("https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=2645805879,3182406483&fm=224&gp=0.jpg", fit: BoxFit.cover,),
        //Image.asset('assets/images/txr.jpg', fit: BoxFit.fitWidth,),
      ),
    );

    return Container(
      //height: 100,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))
      ),
      //margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      //padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Image.asset('assets/images/txr.jpg', fit: BoxFit.fitWidth),
    );
  }

  // 内容部分
  Widget PublishContentArea() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 书名
          Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
              child: Text(book.bookName, maxLines: 2,),
          ),
          // 价格
          Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: RichText(
                text: TextSpan(
                  children: [
                    // 设定价格
                    TextSpan(text: "￥", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500)),
                    // 整数部分
                    TextSpan(text: book.price_now.toInt().toString() + '.', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.w700)),
                    // 小数部分
                    TextSpan(text: book.price_now.toStringAsFixed(2).split('.')[1], style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w700)),
                    TextSpan(text: "  "),
                    TextSpan(
                        text: "￥${book.price_origin.toStringAsFixed(2)}",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.grey,
                        )
                    ),
                  ],
                ),
              ),
          ),
          // 标签tag
          Row(
            children: [
              // 折扣
              // 如果原价是0, 会出现计算错误, 必须判断一下
              // 不能大于等于10折, 或者是0折
              this.book.price_origin != 0 && (book.price_now / book.price_origin < 1 && book.price_now / book.price_origin > 0) ?
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.7, color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                    ),
                    // 这里, 原价不能为 0
                    child: Text("二手${(book.price_now / book.price_origin * 10).round()}折", style: TextStyle(fontSize: 9, color: Colors.red, letterSpacing: 0.5),),
                  ),
                ) : Container(padding: EdgeInsets.only(left: 5),),
              // 品相
              Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.7, color: Colors.red),
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                  child: Text(ShopBookModel.appearanceList[book.appearance], style: TextStyle(fontSize: 9, color: Colors.red, letterSpacing: 0.5),),
                ),
              ),
              // 运费
              book.expressPrice == 0.0 ?
              Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 10, 0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.7, color: Colors.red),
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                  child: Text("包邮", style: TextStyle(fontSize: 9, color: Colors.red, letterSpacing: 0.5),),
                ),
              ) : Container(),
            ],
          ),
        ],
      ),
    );
  }


  // 用户信息部分
  Widget UserInfoArea() {
    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 头像
          Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 5, 10),
            //padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
            child: CircleAvatar(
              radius: 8,
              //backgroundImage: AssetImage('assets/images/txr.jpg'),
              child: Icon(Icons.person, size: 10,),
            ),
          ),

          // 发布者用户名
          Padding(
            padding: EdgeInsets.zero,
            child: FutureBuilder(
              future: getUserInfo(),
              builder: (context, snapshot) {
                return Text(book.owner.userName, style: TextStyle(fontSize: 12, color: Colors.black54),);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: impleement build
    return GestureDetector(
      onTap: () {
        /*
        Navigator.of(context).push(MaterialPageRoute(
          settings: RouteSettings(name: "ShopDetailPage"),
            builder: (context) => ShopBookDetailPage(this.book)
        ));

         */

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => ShopBookDetailPage(this.book)),
                (Route<dynamic> route) {
              //返回的是false的都会被从路由队列里面清除掉
              return route.isFirst;
            });
      },
      child: Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(4)),
          border: Border.all(width: 0.2, color: Colors.black26),
          // gradient: LinearGradient(colors: [Colors.white, Colors.black12]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CoverArea(),
            PublishContentArea(),
            UserInfoArea(),
          ],
        ),
      ),
    );
  }
}