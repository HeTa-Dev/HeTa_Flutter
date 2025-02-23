import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:heta/entity/post_view.dart';
import '../post_view_detail_page.dart';

// 这是自定义的用于在主页面上显示postView的容器
class PostViewContainer extends StatefulWidget {
  final PostView postView;

  // 构造方法需要postView中的信息
  PostViewContainer({required this.postView});

  @override
  State<StatefulWidget> createState() {
    return _PostViewContainer();
  }
}

class _PostViewContainer extends State<PostViewContainer> with AutomaticKeepAliveClientMixin<PostViewContainer> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // 用GestureDetector包裹Container是为了给它加上点击事件，即查看postView详情
    return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder:(context)=>PostViewDetailPage(postView: widget.postView)));
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
                    double height = width*(widget.postView.coverHeight!/widget.postView.coverWidth!);

                    return Container(
                      height: height, // 使用计算后的高度
                      child: CachedNetworkImage(
                        imageUrl: widget.postView.coverImagePath,
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
                      widget.postView.title,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.postView.userName,
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