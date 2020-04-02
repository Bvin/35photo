import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
  int _lastId = 4501815;

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
        queryParameters: {
          "type": "getNextPageData",
          "page": "genre",
          "lastId": lastId,
          "community_id": genreId,
          "photo_rating": "35",
        }
    );
    String data = response.data;
    print(data);
    Map map = json.decode(data);
    //_lastId = map["lastId"];
    print(map["data"]);
  }

}

