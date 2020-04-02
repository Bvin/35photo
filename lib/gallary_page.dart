import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:html/dom.dart' as html;

class GalleryPage extends StatefulWidget{

  final List<html.Element> photos;
  final int position;

  GalleryPage(this.photos, this.position);


  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}
class PageState extends State<GalleryPage>{

  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.position);
    _pageController.addListener((){
      int index = _pageController.page.floor();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: Stack(
      children: <Widget>[
        PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: widget.photos.length,
            builder: (BuildContext context, int index) {
              var url = widget.photos[index].attributes["src"];
              int id;
              //url = "https://m1.35photo.pro/photos_main/900/$id.jpg";
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(url),
              );
            }
        ),
        Container(
          margin: EdgeInsets.only(bottom: 25),
          child: ListTile(
            leading: GestureDetector(child: Icon(Icons.keyboard_backspace),onTap: (){
              Navigator.of(context).pop();
            },),
            trailing: GestureDetector(child: Icon(Icons.zoom_out_map), onTap: (){
              var url = widget.photos[_pageController.page.floor()].attributes["url"];
              url = "https://gallery.1x.com" + url.replaceAll("ld", "hd4");
            },),
          ),
        )
      ] ,
      alignment: Alignment.bottomCenter,
    ),),theme: ThemeData.dark(),);
  }

}
