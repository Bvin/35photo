import 'package:flutter/material.dart';

class GenresPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}

class PageState extends State<GenresPage>{

  List<Map> _genres;

  @override
  void initState() {
    super.initState();
  }

  loadGenres(){
    _genres = <Map>[
      {
        "name":"Landscapes",
        "image":"https://m1.35photo.pro/photos_temp/sizes/899/4497822_1000n.jpg",
        "url":"https://35photo.pro/genre_99/",
      },
      {
        "name":"Portrait",
        "image":"https://m1.35photo.pro/photos_temp/sizes/898/4494813_1000n.jpg",
        "url":"https://35photo.pro/genre_96/",
      },
      {
        "name":"Fine Nudes",
        "image":"https://m1.35photo.pro/photos_temp/sizes/899/4497822_1000n.jpg",
        "url":"https://35photo.pro/genre_99/",
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return grid();
  }

  grid(){
    return GridView.count(
        children: <Widget>[],
        crossAxisCount: 3
    );
  }
}