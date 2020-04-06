import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart'as html;

import 'genres_photo.dart';

class GenresPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}

class PageState extends State<GenresPage>{

  List<Map> _genres = List();
  bool _showLoading = false;

  @override
  void initState() {
    loadHtml();
    super.initState();
  }

  loadHtml() async {
    _showLoading = true;
    setState(() {});
    Dio dio = Dio();
    Response response = await dio.get("https://35photo.pro/genre/",
        options: Options(headers: {"Cookie":"nude=true"})//nude
    );
    html.Document document = html.Document.html(response.data);
    List<html.Element> element = document.getElementsByClassName("parentGenre");
    element.forEach((e){
      Map map = Map();
      html.Element element1 = e.children[0];
      var style = element1.attributes["style"];
      RegExp regExp = RegExp("http.*?jpg");
      Match match = regExp.firstMatch(style);
      String background = match.group(0);
      map["background"] = background;

      html.Element element2 = e.children[1];
      html.Element a = element2.children[0];
      String url = a.attributes["href"];
      String name = a.text;
      map["url"] = url.substring(url.lastIndexOf('_')+1,url.lastIndexOf('/'));
      map["name"] = name;
      print(map);
      _genres.add(map);
    });
    _showLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return grid();
  }

  grid(){
    if(_genres == null) return Container();
    return GridView.count(
        children: _genres.map((map) =>
            gridItem(map["name"], map["background"], map["url"], () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                    builder: (ctx)=>GenresPhotoPage(map["url"]))
                );
            })).toList(),
        childAspectRatio: 2,
        crossAxisCount: 2,
    );
  }

  Widget gridItem(String genre, imageUrl, url, onTap) {
    return GestureDetector(
      child: Container(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(genre.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white
                ),
              ),
            )
          ],
          alignment: Alignment.bottomCenter,
        ),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: CachedNetworkImageProvider(imageUrl),
                fit: BoxFit.cover
            )
        ),
      ),
      onTap: onTap,
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
}