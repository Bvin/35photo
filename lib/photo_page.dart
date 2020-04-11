import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoPage extends StatefulWidget{

  final String url;

  PhotoPage(this.url);

  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}

class PageState extends State<PhotoPage>{
  @override
  Widget build(BuildContext context) {
    return PhotoView(imageProvider: CachedNetworkImageProvider(widget.url),);
  }

}