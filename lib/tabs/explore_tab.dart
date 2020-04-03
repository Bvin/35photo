import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ExploreTab extends StatefulWidget{

  final List<Map> authors;

  ExploreTab(this.authors);

  @override
  State<StatefulWidget> createState() {
    return TabState();
  }
}

class TabState extends State<ExploreTab>{

  @override
  void initState() {
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

  body() {
    return NestedScrollView(
        headerSliverBuilder: (buildContext, innerBoxIsScrolled) => <Widget>[
          SliverAppBar(
            title: title(),
          )
        ],
        body: Container(),
    );
  }

  title() {
    return PageView.builder(
        itemCount: widget.authors.length,
        itemBuilder: (ctx, index) => author(widget.authors[index])
    );
  }

  Widget author(map){
    return Column(
      children: <Widget>[
        Row(children: <Widget>[
          CircleAvatar(backgroundImage: CachedNetworkImageProvider(map["avatar"]),),
          Text(map["author"]),
        ],),
        Row(
          children: map["photos"].map((m)=> GestureDetector(
            child: CachedNetworkImage(imageUrl: m["img"]),
            onTap: (){
              print(m["url"]);
            },
          )).toList(),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        )
      ],
    );
  }

}

