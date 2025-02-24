import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:heta/entity/order_view.dart';
import 'package:heta/page/order_view_detail_page.dart';


// 这是自定义的用于在主页面上显示orderView的容器
class OrderViewContainer extends StatefulWidget {
  final OrderView orderView;

  // 构造方法需要orderView中的信息
  OrderViewContainer({required this.orderView});

  @override
  State<StatefulWidget> createState() {
    return _OrderViewContainer();
  }
}

// flutter会自动将滑出屏幕的一些元件清除，这会导致在页面快速滑动的时候，不断重复build。
// 由于我们目前还没有很好地利用占位符，图片加载的时候很奇怪，因为文字比图片加载得更快。
// 本来UI在build的时候就会有伸缩。这样会给用户带来很不好的体验
// 所以这里我们告诉flutter框架不要清理这个自定义Container。
// 最终效果就是页面只会在刚进入的时候伸缩一次，用户体验好了很多，但也会占用更多内存。
// 2024.8.3 最新情况：占位符已经实现了根据图片尺寸自适应，
// 但这里不打算改了，因为不改的话用户体验更好
class _OrderViewContainer extends State<OrderViewContainer> with AutomaticKeepAliveClientMixin<OrderViewContainer> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // 用GestureDetector包裹Container是为了给它加上点击事件，即查看orderView详情
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder:(context)=>OrderViewDetailPage(orderView: widget.orderView)));
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.zero,
                bottomRight: Radius.zero,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double width = constraints.maxWidth; // 获取容器的宽度
                  double height = width*(widget.orderView.coverHeight!/widget.orderView.coverWidth!);

                  return Container(
                    height: height, // 使用计算后的高度
                    child: CachedNetworkImage(
                      imageUrl: widget.orderView.coverImagePath,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5), // 为ClipRRect外的元素设置边距
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.orderView.title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "\¥${widget.orderView.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.orderView.sellerName,
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}