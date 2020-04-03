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
        body: SafeArea(child: body()),
      ),
      theme: ThemeData.dark(),
    );
  }

  body() {
    return NestedScrollView(
        headerSliverBuilder: (buildContext, innerBoxIsScrolled) => <Widget>[
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: title(),
            ),
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
    return Padding(padding: EdgeInsets.all(15), child: Column(
      children: <Widget>[
        Row(children: <Widget>[
          Padding(padding: EdgeInsets.only(right: 10, bottom: 10),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(map["avatar"]),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 10),
              child: Text(map["author"], style: TextStyle(fontSize: 18),)),
        ],),
        Row(
          children: imgs(map["photos"]),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        )
      ],
    ),);
  }

  List<Widget> imgs(List<Map> maps){
    return maps.map((m) => clickImage(m)).toList();
  }

  Widget clickImage(m){
    return GestureDetector(
      child: CachedNetworkImage(imageUrl: m["img"], fit: BoxFit.cover,height: 100,),
      onTap: (){
        print(m["url"]);
      },
    );
  }

  authors(map){
    return Row(children: <Widget>[
      CircleAvatar(backgroundImage: CachedNetworkImageProvider(map["avatar"]),),
      Text(map["author"]),
    ],);
  }

  images(map){
    return Row(
      children: map["photos"].map((m)=> GestureDetector(
        child: CachedNetworkImage(imageUrl: m["img"]),
        onTap: (){
          print(m["url"]);
        },
      )).toList(),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}

