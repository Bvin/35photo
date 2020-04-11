import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as html;

class CommunityPage extends StatefulWidget{

  final String url;

  CommunityPage(this.url);

  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}

class PageState extends State<CommunityPage>{

  Dio _dio;

  bool _loading = false;
  List<html.Element> _photos;

  @override
  void initState() {
    _dio = Dio();
    _photos = List();
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_photos.isEmpty) return Center(child: CircularProgressIndicator(),);
    return GridView.count(
      crossAxisCount: 2,
      children: _photos.map((e) =>
          CachedNetworkImage(imageUrl: e.attributes["src"])).toList(),
    );
  }

  load() async {
    _loading = true;
    setState(() {});
    Response response = await _dio.get(widget.url);
    html.Document document = html.Document.html(response.data);
    _photos.addAll(document.getElementsByClassName("prevr2"));
    _loading = false;
    setState(() {});
  }

}