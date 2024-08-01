import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heta/entity/order_view.dart';

class OrderViewContainer extends StatefulWidget {
  final OrderView orderView;

  OrderViewContainer({required this.orderView});

  @override
  State<StatefulWidget> createState() {
    return _OrderViewContainer();
  }
}

class _OrderViewContainer extends State<OrderViewContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: widget.orderView.coverImagePath,
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          Text(
            widget.orderView.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 5),
          Text(
            "\¥${widget.orderView.price.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
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
    );
  }
}