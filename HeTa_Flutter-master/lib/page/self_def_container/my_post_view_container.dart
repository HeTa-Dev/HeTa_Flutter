import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heta/entity/post_view.dart';
import '../post_view_detail_page.dart';

// 这是自定义的用于在主页面上显示postView的容器
class MyPostViewContainer extends StatefulWidget {
  final PostView postView;

  // 构造方法需要postView中的信息
  MyPostViewContainer({required this.postView});

  @override
  State<StatefulWidget> createState() {
    return _PostViewContainer();
  }
}

// flutter会自动将滑出屏幕的一些元件清除，这会导致在页面快速滑动的时候，不断重复build。
// 由于我们目前还没有很好地利用占位符，图片加载的时候很奇怪，因为文字比图片加载得更快。
// 本来UI在build的时候就会有伸缩。这样会给用户带来很不好的体验
// 所以这里我们告诉flutter框架不要清理这个自定义Container。
// 最终效果就是页面只会在刚进入的时候伸缩一次，用户体验好了很多，但也会占用更多内存。
// 2024.8.3 最新情况：占位符已经实现了根据图片尺寸自适应，
// 但这里不打算改了，因为不改的话用户体验更好
class _PostViewContainer extends State<MyPostViewContainer> with AutomaticKeepAliveClientMixin<MyPostViewContainer> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // 用GestureDetector包裹Container是为了给它加上点击事件，即查看postView详情
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PostViewDetailPage(postView: widget.postView)));
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
                      widget.postView.title,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.postView.userName,
                      style: TextStyle(fontSize: 10),
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
                    imageUrl: widget.postView.coverImagePath,
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