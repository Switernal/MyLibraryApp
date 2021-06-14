import 'package:flutter/material.dart';
// Packages
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:my_library/Functions/Utils/Utils.dart';

// Pages
import 'package:my_library/MyBook/Controller/Book/MyBookDetailPage.dart';

// Functions
import 'package:my_library/MyBook/Function/SearchBookByISBN_Bamboo.dart';
import 'package:my_library/MyBook/Model/MyBookModel.dart';

class BookCard extends StatelessWidget {
  final BookCardViewModel data;
  final MyBookModel thisBook;

  const BookCard({Key key, this.data, @required this.thisBook}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double coverSize = 110;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
            MyBookDetailPage(thisBook: thisBook, isCollected: true,)
        ));
        //SearchBookByISBN.searchBookByISBN(ISBN: "9787569377941", context: context);
        /*
        Scaffold.of(context).showToast(SnackBar(
          content: Row(
            children: <Widget>[
              Icon(Icons.search,color: Colors.white,),
              Padding(padding: EdgeInsets.all(5),),
              Text('正在查找图书...')],
          ),
          action: SnackBarAction(

            label: '隐藏',
            onPressed: (){},
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ));
        */
      },
      child: Column(
        children: <Widget>[
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                fit: StackFit.passthrough,
                children: <Widget>[
                  /*
                  Image.network(
                    this.data.coverURL,
                    fit: BoxFit.cover,
                  ),

                   */
                  // 从普通图片改为网络缓存图
                  /*
                  CachedNetworkImage(
                    imageUrl: this.data.coverURL,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(padding: EdgeInsets.all(20),child: Center(child: AspectRatio(aspectRatio: 1, child: CircularProgressIndicator(strokeWidth: 4,),),),),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),

                   */
                  AspectRatio(
                    aspectRatio: 3.0/4.0,
                    child: ExtendedImage.network(
                      this.data.coverURL,
                      cache: true,
                      fit: BoxFit.cover,
                      enableLoadState: true,
                      loadStateChanged: (state) {
                        return Utils.loadNetWorkImage(state);
                      },
                    ),
                  ),

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: coverSize / 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color.fromARGB(100, 0, 0, 0)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Icon(
                            Icons.menu_book,
                            color: Colors.white,
                            size: 12,
                          ),
                          Padding(padding: EdgeInsets.only(left: 5)),
                          
                          // 如果阅读量为0, 则不显示文字
                          Text(
                            (this.data.readProgress == 0) ? "" :
                            //Helper.numFormat(this.data.playsCount),
                            '已读' + Helper.numFormat(this.data.readProgress) + '页',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  !this.data.needVip ? null : Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(5, 2, 10, 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomRight: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                            colors: [Color(0xFFA17551), Color(0xFFCCBEB5)]),
                      ),
                      child: Text(
                        'VIP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ].where((item) => item != null).toList(),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 5)),
          Container(
            height: 30,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                this.data.bookName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),

                ),
              ),
            ),
          ),
          // SizedBox(
          //   height: 28,
          //   child: Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 0),
          //     child: Text(
          //       this.data.title,
          //       maxLines: 2,
          //       overflow: TextOverflow.ellipsis,
          //       textAlign: TextAlign.left,
          //       style: TextStyle(
          //         fontSize: 10,
          //         fontWeight: FontWeight.w500,
          //         color: Color(0xFF333333),
          //
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class Helper {
  static String numFormat(int num) {
    if (num / 10000 < 1) {
      return '${num}';
    } else if (num / 100000000 < 1) {
      return '${num ~/ 10000}万';
    } else {
      return '${num ~/ 100000000}亿';
    }
  }
}

class BookCardViewModel {
  /// 书名
  final String bookName;

  /// 阅读进度
  final int readProgress;

  /// 封面图地址
  final String coverURL;

  /// 是否需要vip才能观看
  final bool needVip;

  const BookCardViewModel({
    @required this.bookName,
    this.readProgress = 0,
    this.coverURL = "about:blank",
    this.needVip = false,
  });
}
