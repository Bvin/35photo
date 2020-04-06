import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotosPage extends StatefulWidget{

  final String url;

  PhotosPage(this.url);

  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}
class PageState extends State<PhotosPage>{

  var _dio;
  Map _photoData;
  List _series;
  List _others;

  @override
  void initState() {
    _dio = Dio();
    load();
    super.initState();
  }

  load() async {
    Response response = await _dio.get(widget.url);
    String html = response.data;
    String startPref = "photoData = ";
    int start = html.indexOf(startPref) + startPref.length;
    int end = html.lastIndexOf("};") + 1;
    String json = html.substring(start,end);
    _photoData = jsonDecode(json);
    if(_photoData.containsKey("series")){
      _series = _photoData["series"];
    }
    _others = _photoData["other_photos"];
    print(_series);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: page(),
    );
  }

  page(){
    if(_photoData == null){
      return Container();
    }
    return PageView.builder(
      itemCount: _series == null ? 2 : _series.length + 1,
      itemBuilder: (ctx, index) {
        if(_series == null){
          if(index == 0){
            return PhotoView(imageProvider: CachedNetworkImageProvider(_photoData["src"]));
          }else{
            return grid();
          }
        }else{
          if(index == _series.length){
            return grid();
          }else{
            return PhotoView(imageProvider: CachedNetworkImageProvider(_series[index]["src"]));
          }
        }
      },
    );
  }

  grid() {
    return GridView.count(
      crossAxisCount: 3,
      children: _others.map((map) => CachedNetworkImage(imageUrl: map["src"])).toList(),
    );
  }

}