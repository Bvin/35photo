import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    _dio = Dio();
    load();
    super.initState();
  }

  load() async {
    Response response = await _dio.get(widget.url);
    String html = response.data;
    int start = html.indexOf("photoData = {");
    int end = html.lastIndexOf("};");
    String json = html.substring(start,end);
    print("$start-$end=>$json");
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}