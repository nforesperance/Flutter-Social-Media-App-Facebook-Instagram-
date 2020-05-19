import 'package:buddiesgram/pages/PostScreenPage.dart';
import 'package:buddiesgram/widgets/PostWidget.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  final Post post;

  const PostTile({Key key, this.post}) : super(key: key);

  displayFullPost(context){
     Navigator.push(context, 
     MaterialPageRoute(builder: (context)=>PostScreenPage(postID:post.postID,
     userId:post.ownerId
     ))
     );
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:() => displayFullPost(context),
      child:Image.network(post.url) ,
      
    );
  }
}
