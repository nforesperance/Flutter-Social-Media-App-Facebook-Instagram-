import 'package:buddiesgram/widgets/PostWidget.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  final Post post;

  const PostTile({Key key, this.post}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child:Image.network(post.url) ,
      
    );
  }
}
