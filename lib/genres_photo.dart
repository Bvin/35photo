import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:html/dom.dart' as html;

class GenresPhotoPage extends StatefulWidget{

  final genreId;

  GenresPhotoPage(this.genreId);

  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}
class PageState extends State<GenresPhotoPage>{

  Dio _dio;
  bool _showLoading = false;
  List<Map> _photos;
  int _lastId = 0;

  @override
  void initState() {
    _dio = Dio();
    load(widget.genreId, _lastId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: body(),
      ),
    );
  }

  body(){
    List<Widget> children = [];
    if(_photos != null){
      children.add(grid());
    }
    children.add(loading());
    return Stack(children: children,);
  }
  grid(){
    return StaggeredGridView.countBuilder(
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        crossAxisCount: 2,
        itemCount: _photos.length,
        itemBuilder: (ctx,index)=> GestureDetector(
          child: CachedNetworkImage(imageUrl: _photos[index]["img"]),
        ),
        staggeredTileBuilder: (index) => StaggeredTile.fit(1),
    );
  }

  loading(){
    return Center(
      child: Visibility(
        child: CircularProgressIndicator(),
        visible: _showLoading,
      ),
    );
  }

  load(genreId, lastId) async {
    print(genreId);
    Response response = await _dio.get("https://m1.35photo.pro/show_block.php",
        options: Options(headers: {
          "Cookie":"user_lang=en; _ga=GA1.2.1675562080.1585727189; _gid=GA1.2.1999997836.1585727189; _fbp=fb.1.1585727189511.1481881805; _ym_uid=15857915721044290429; _ym_d=1585791572; _ym_isad=2; user_login=bvin; token2=300d307489ac74db963ce362ae43833d; user_status=new; nude=true; me=fe9c78a3ad3f2178a32a04050d5de96d; session=6kcskbrq7ngidcgkhr60l9pkuh; user_lastEnter=1585818915 If-Modified-Since: Thu, 02 Apr 2020 09:14:48 GMT",
        }),
        queryParameters: {
          "type": "getNextPageData",
          "page": "genre",
          "lastId": lastId,
          "community_id": genreId,
          "photo_rating": "35",
        }
    );
    String data = response.data;
    Map map = json.decode(data);
    //_lastId = map["lastId"];
    html.Document document = html.Document.html(map["data"]);
    List<html.Element> elements = document.getElementsByClassName("showPrevPhoto");
    elements.forEach((e){
      String src = e.attributes["src"];
      String alt = e.attributes["alt"];
      String title = e.attributes["title"];
      print(e);
    });

    //print(map["data"]);
  }

}

