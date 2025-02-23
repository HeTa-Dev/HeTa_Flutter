import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:heta/entity/order_view.dart';
import '../order_view_detail_page.dart';

// 这是自定义的用于在主页面上显示orderView的容器，这个是搜索界面查看的容器，和主界面展现的帖子形式不一样。
class SearchOrderViewContainer extends StatefulWidget {
  final OrderView orderView;

  // 构造方法需要orderView中的信息
  SearchOrderViewContainer({required this.orderView});

  @override
  State<StatefulWidget> createState() {
    return _OrderViewContainer();
  }
}


class _OrderViewContainer extends State<SearchOrderViewContainer> with AutomaticKeepAliveClientMixin<SearchOrderViewContainer> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // 用GestureDetector包裹Container是为了给它加上点击事件，即查看orderView详情
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => OrderViewDetailPage(orderView: widget.orderView)));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左边四分之三显示标题文字
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.orderView.title,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.orderView.price.toString(),
                      style: TextStyle(fontSize: 30,color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            // 右边四分之一显示正方形图片缩略图
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                child: AspectRatio(
                  aspectRatio: 1 / 1, // 保证图片是正方形
                  child: CachedNetworkImage(
                    imageUrl: widget.orderView.coverImagePath,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}